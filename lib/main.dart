import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart'; // Import the logger package

// Firebase imports for FCM and Crashlytics
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui'; // Required for PlatformDispatcher

// Background service imports
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:geolocator/geolocator.dart'; // For location in background
import 'package:web_socket_channel/web_socket_channel.dart'; // For WebSocket in background
import 'dart:async'; // For Timer in background
import 'dart:convert'; // For jsonDecode - NEW: Explicitly imported for parsing message.data and websocket messages

// Your existing project imports
import 'core/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/leaderboard_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/quest_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/database_helper.dart'; // For local database access in background
import 'data/datasources/local/user_local_datasource_impl.dart'; // For user data in background
import 'data/datasources/local/faculty_local_datasource_impl.dart'; // For faculty data in background
import 'data/datasources/local/quest_local_datasource_impl.dart'; // For quest data in background
import 'data/models/quest_model.dart'; // Assuming you have a QuestModel
import 'data/models/user_model.dart'; // Import your UserModel
import 'data/models/faculty_model.dart'; // Import your FacultyModel

// Global logger instance
final Logger _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // No method calls to be displayed for general app logs
    errorMethodCount: 5, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print emojis
    dateTimeFormat: DateTimeFormat.none, // FIX: Replaced printTime
  ),
);

// ========================================================================
// 1. TOP-LEVEL FUNCTION FOR FCM BACKGROUND MESSAGES
// ========================================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  _logger.i("Background Message Handled: ${message.messageId}");
  _logger.d("Background Message Data: ${message.data}");

  // TODO: Implement logic here to process background quest notifications.
  // This could involve saving the quest data to SQLite via your local datasources.
  final dbHelper = DatabaseHelper(); // Re-initialize in background isolate
  await dbHelper.initDb(); // Ensure DB is initialized
  final questLocalDataSource = QuestLocalDataSourceImpl(dbHelper);
  if (message.data['quest'] != null) {
    try {
      // FIX: Ensure data is properly decoded from string to JSON map
      final questModel = QuestModel.fromJson(jsonDecode(message.data['quest']));
      await questLocalDataSource.saveQuest(questModel);
      _logger.i('Background: Saved quest from FCM: ${questModel.id}');
    } catch (e, stackTrace) {
      _logger.e(
          'Background: Error parsing/saving quest from FCM: $e', e, stackTrace);
    }
  }
}

// ========================================================================
// 2. GLOBAL INSTANCE FOR FLUTTER LOCAL NOTIFICATIONS
// ========================================================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ========================================================================
// 3. BACKGROUND SERVICE ENTRY POINT
// This function runs in a separate Isolate when the background service starts.
// It needs to be a top-level function.
// ========================================================================
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only call ensureInitialized once per Isolate.
  // This is crucial for background Isolates.
  DartPluginRegistrant.ensureInitialized();

  // Initialize Firebase in this background Isolate
  await Firebase.initializeApp();
  // Initialize Crashlytics for background errors
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Initialize local notifications for background service if needed to show notifications
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  // Initialize your database helper and local datasources for background access
  final dbHelper = DatabaseHelper();
  await dbHelper.initDb(); // Ensure DB is initialized
  final userLocalDataSource = UserLocalDataSourceImpl(dbHelper);
  final facultyLocalDataSource = FacultyLocalDataSourceImpl(dbHelper);
  final questLocalDataSource = QuestLocalDataSourceImpl(dbHelper);

  // For Android foreground service notification commands
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setForegroundMode(true); // FIX: Changed to setForegroundMode
    });

    service.on('setAsBackground').listen((event) {
      service.setForegroundMode(false); // FIX: Changed to setForegroundMode
    });
  }

  // Listen for stop command from the main Isolate
  service.on('stopService').listen((event) {
    service.stopSelf();
    _logger.i('Background service stopped.');
  });

  // ======================================================================
  // BACKGROUND SERVICE LOGIC:
  // Continuous Location Tracking & Real-time Leaderboard Streaming
  // ======================================================================

  // --- Location Tracking Placeholder ---
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    ),
  ).listen((Position position) async {
    _logger
        .d('Background Location: ${position.latitude}, ${position.longitude}');
    // TODO: Process location data (e.g., calculate distance for a quest)
    // Save to local database or send to backend.
    // FIX: Changed to invoke with a meaningful event name
    service.invoke('update_location', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': position.timestamp.toIso8601String()
    });
  });

  // --- Real-time Leaderboard Streaming Placeholder (WebSocket) ---
  final wsUrl =
      Uri.parse('WebSocket server started on ws://localhost:8080/leaderboard');
  WebSocketChannel? channel;

  void connectWebSocket() {
    try {
      channel = WebSocketChannel.connect(wsUrl);
      _logger.i('WebSocket: Attempting to connect to $wsUrl');

      channel?.stream.listen(
        (message) async {
          _logger.d('WebSocket: Received: $message');
          // TODO: Process leaderboard update message
          // Parse message (e.g., JSON), update local SQLite database.
          try {
            // FIX: Ensure data is properly decoded from string to JSON map
            final Map<String, dynamic> leaderboardData = jsonDecode(message);

            // Assuming your local datasources have corresponding save methods
            if (leaderboardData.containsKey('faculties') &&
                leaderboardData['faculties'] is List) {
              final List<FacultyModel> faculties = (leaderboardData['faculties']
                      as List)
                  .map((e) => FacultyModel.fromJson(e as Map<String, dynamic>))
                  .toList();
              await facultyLocalDataSource.saveFaculties(faculties);
              _logger.i(
                  'Background: Saved ${faculties.length} faculties from WebSocket.');
            }

            if (leaderboardData.containsKey('users') &&
                leaderboardData['users'] is List) {
              final List<UserModel> users = (leaderboardData['users'] as List)
                  .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                  .toList();
              await userLocalDataSource
                  .saveUsers(users); // If you have a saveUsers method
              _logger
                  .i('Background: Saved ${users.length} users from WebSocket.');
            }

            // Send update to the UI if it's active
            // FIX: Changed to invoke with a meaningful event name
            service.invoke('leaderboard_update', leaderboardData);
          } catch (e, stackTrace) {
            _logger.e(
                'Background: Error parsing/processing WebSocket message: $e',
                e,
                stackTrace);
          }
        },
        onDone: () {
          _logger.w('WebSocket: Disconnected. Attempting to reconnect...');
          Timer(const Duration(seconds: 5), connectWebSocket);
        },
        onError: (error, stackTrace) {
          // Added stackTrace here for better logging
          _logger.e('WebSocket Error: $error', error, stackTrace);
          Timer(const Duration(seconds: 5), connectWebSocket);
        },
        cancelOnError: true, // Cancel stream on error, then reconnect
      );
    } catch (e, stackTrace) {
      // Added stackTrace here for better logging
      _logger.e('WebSocket Connection Error: $e', e, stackTrace);
      Timer(const Duration(seconds: 5), connectWebSocket);
    }
  }

  connectWebSocket(); // Initial connection

  // --- Example: Send data to the UI periodically (for demonstration) ---
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      // Update foreground notification (Android only)
      service.setForegroundNotificationInfo(
        title: "Campus Pulse Background Service",
        content: "Tracking location and leaderboard updates",
      );
    }

    // Example of sending data to the main Isolate
    // FIX: Changed to invoke, used a descriptive event name
    service.invoke('update_status', {
      "current_timestamp": DateTime.now().toIso8601String(),
      "is_running": true,
      // You can send aggregated location data or status here
    });
  });
}

// ========================================================================
// 4. MAIN FUNCTION - Entry point of the Flutter application
// ========================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize Firebase Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set up the background message handler for FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ======================================================================
  // 5. INITIALIZE FLUTTER LOCAL NOTIFICATIONS PLUGIN
  // ======================================================================
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      _logger.d('iOS Local Notification (Foreground): $title, $body, $payload');
      // You might want to handle this differently, e.g., show a dialog
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      _logger.d('Notification Response Payload: ${response.payload}');
      if (response.payload != null && response.payload!.isNotEmpty) {
        _logger
            .i('Navigating to quest with ID from payload: ${response.payload}');
        // Ensure router is available before navigating
        if (AppRouter.router.canPop() || AppRouter.router.location == '/') {
          // Check if we can pop current route or go directly to avoid issues on cold start
          AppRouter.router.go(AppConstants.activeQuestRoute);
        } else {
          // This case handles cold start when the router might not be fully initialized
          // A common pattern is to store the payload and navigate once the app is ready.
          // For now, we just log a warning.
          _logger.w(
              'Router not immediately ready for navigation from notification tap. Payload: ${response.payload}');
        }
      }
    },
  );

  // ======================================================================
  // 6. REQUEST NOTIFICATION PERMISSIONS (iOS & Android 13+)
  // ======================================================================
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  _logger.i(
      'User notification permission status: ${settings.authorizationStatus}');

  // ======================================================================
  // 7. GET FCM TOKEN AND SEND TO YOUR BACKEND
  // ======================================================================
  String? fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    _logger.i("FCM Device Token: $fcmToken");
    // TODO: Send this `fcmToken` to your application's backend.
  } else {
    _logger.w("FCM Device Token is null.");
  }

  // ======================================================================
  // 8. LISTEN FOR FCM MESSAGES WHEN APP IS IN FOREGROUND
  // ======================================================================
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _logger.i('FCM Message Received in Foreground!');
    _logger.d('Message data: ${message.data}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'quest_channel',
            'Quest Notifications',
            channelDescription: 'Notifications for new and active quests',
            icon: android.smallIcon,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['questId'],
      );
      _logger
          .i('Local notification shown for FCM message: ${notification.title}');
    } else {
      _logger.w(
          'FCM foreground message received, but no notification payload to display.');
    }
  });

  // ======================================================================
  // 9. LISTEN FOR FCM MESSAGES WHEN APP IS OPENED FROM NOTIFICATION TAP
  // ======================================================================
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _logger.i('FCM Message opened app from background/terminated state!');
    _logger.d('Notification Data: ${message.data}');
    if (message.data['questId'] != null) {
      _logger.i(
          'Navigating to quest with ID from opened app: ${message.data['questId']}');
      AppRouter.router.go(AppConstants.activeQuestRoute);
    } else {
      _logger.w('FCM opened app message received, but no questId in payload.');
    }
  });

  // ======================================================================
  // 10. INITIALIZE AND START FLUTTER BACKGROUND SERVICE
  // ======================================================================
  final service = FlutterBackgroundService();

  await service.configure(
    // FIX: Removed top-level onStart, now it's only in Android/iOS configs
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // The top-level function that will be executed
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'my_foreground_service_channel',
      initialNotificationTitle: 'Campus Pulse Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888, // Unique ID for foreground service
    ),
    iosConfiguration: IosConfiguration(
      onStart: onStart, // The top-level function that will be executed
      autoStart: true,
      onForeground: onStart, // FIX: Changed onForeground to onStart
      onBackground: onStart, // FIX: Changed onBackground to onStart
    ),
  );

  service.startService(); // Start the background service

  // ======================================================================
  // 11. RUN THE FLUTTER APP
  // ======================================================================
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// ========================================================================
// 12. MYAPP WIDGET
// ========================================================================
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final AppTheme currentTheme = ref.watch(themeProvider);

    // FIX: Listen to background service updates for UI
    final FlutterBackgroundService _backgroundService =
        FlutterBackgroundService();
    _backgroundService.on('leaderboard_update').listen((data) {
      if (data != null) {
        _logger.d(
            'Main Isolate: Received leaderboard_update from background service: $data');
        // Trigger a refresh of the leaderboard provider
        ref
            .read(leaderboardProvider.notifier)
            .fetchLeaderboard(); // Assuming you have a fetchLeaderboard method
        ref
            .read(profileProvider.notifier)
            .fetchUserProfile(); // Assuming you have a fetchUserProfile method if user data is updated
      }
    });

    _backgroundService.on('update_location').listen((data) {
      if (data != null) {
        _logger.d(
            'Main Isolate: Received location update from background service: $data');
        // You might want to update a UI provider or state here if needed
      }
    });

    _backgroundService.on('update_status').listen((data) {
      if (data != null) {
        _logger.d(
            'Main Isolate: Received status update from background service: $data');
        // Update a UI element to show service status
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Campus Pulse',
      theme: currentTheme.toThemeData(),
    );
  }
}
