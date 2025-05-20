import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

// ========================================================================
// 1. TOP-LEVEL FUNCTION FOR FCM BACKGROUND MESSAGES
// ========================================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  print("Background Message Handled: ${message.messageId}");
  print("Background Message Data: ${message.data}");

  // TODO: Implement logic here to process background quest notifications.
  // This could involve saving the quest data to SQLite via your local datasources.
  // Example:
  // final dbHelper = DatabaseHelper();
  // final questLocalDataSource = QuestLocalDataSourceImpl(dbHelper);
  // if (message.data['quest'] != null) {
  //   final questModel = QuestModel.fromJson(message.data['quest']);
  //   await questLocalDataSource.saveQuest(questModel);
  // }
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
  final userLocalDataSource = UserLocalDataSourceImpl(dbHelper);
  final facultyLocalDataSource = FacultyLocalDataSourceImpl(dbHelper);
  final questLocalDataSource = QuestLocalDataSourceImpl(dbHelper);

  // For Android foreground service notification
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForeground(true);
    });

    service.on('setAsBackground').listen((event) {
      service.setAsForeground(false);
    });
  }

  // Listen for stop command from the main Isolate
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // ======================================================================
  // BACKGROUND SERVICE LOGIC:
  // Continuous Location Tracking & Real-time Leaderboard Streaming
  // ======================================================================

  // --- Location Tracking Placeholder ---
  // You would typically start location tracking here.
  // Ensure you have necessary permissions handled in the main app.
  // This stream will run continuously as long as the service is active.
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    ),
  ).listen((Position position) async {
    print('Background Location: ${position.latitude}, ${position.longitude}');
    // TODO: Process location data (e.g., calculate distance for a quest)
    // Save to local database or send to backend.
    // Example: service.sendData({'location': {'latitude': position.latitude, 'longitude': position.longitude}});
  });

  // --- Real-time Leaderboard Streaming Placeholder (WebSocket) ---
  // Connect to your WebSocket server.
  // Replace with your actual WebSocket URL
  final wsUrl = Uri.parse('ws://your-backend-websocket-url/leaderboard');
  WebSocketChannel? channel;

  void connectWebSocket() {
    try {
      channel = WebSocketChannel.connect(wsUrl);
      print('WebSocket: Attempting to connect to $wsUrl');

      channel?.stream.listen(
        (message) async {
          print('WebSocket: Received: $message');
          // TODO: Process leaderboard update message
          // Parse message (e.g., JSON), update local SQLite database.
          // Example:
          // final Map<String, dynamic> leaderboardData = jsonDecode(message);
          // await facultyLocalDataSource.saveFaculties(leaderboardData['faculties']);
          // await userLocalDataSource.saveUsers(leaderboardData['users']); // If you have a saveUsers method

          // Send update to the UI if it's active
          service.sendData({'leaderboard_update': message});
        },
        onDone: () {
          print('WebSocket: Disconnected. Attempting to reconnect...');
          // Implement reconnection logic
          Timer(const Duration(seconds: 5), connectWebSocket);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          // Implement reconnection logic on error
          Timer(const Duration(seconds: 5), connectWebSocket);
        },
        cancelOnError: true, // Cancel stream on error, then reconnect
      );
    } catch (e) {
      print('WebSocket Connection Error: $e');
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
    service.sendData({
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
      print('iOS Local Notification (Foreground): $title, $body, $payload');
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('Notification Response Payload: ${response.payload}');
      if (response.payload != null && response.payload!.isNotEmpty) {
        print('Navigating to quest with ID from payload: ${response.payload}');
        AppRouter.router.go(AppConstants.activeQuestRoute);
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
  print('User notification permission status: ${settings.authorizationStatus}');

  // ======================================================================
  // 7. GET FCM TOKEN AND SEND TO YOUR BACKEND
  // ======================================================================
  String? fcmToken = await messaging.getToken();
  print("FCM Device Token: $fcmToken");
  // TODO: Send this `fcmToken` to your application's backend.

  // ======================================================================
  // 8. LISTEN FOR FCM MESSAGES WHEN APP IS IN FOREGROUND
  // ======================================================================
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('FCM Message Received in Foreground!');
    print('Message data: ${message.data}');
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
    }
  });

  // ======================================================================
  // 9. LISTEN FOR FCM MESSAGES WHEN APP IS OPENED FROM NOTIFICATION TAP
  // ======================================================================
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('FCM Message opened app from background/terminated state!');
    print('Notification Data: ${message.data}');
    if (message.data['questId'] != null) {
      print(
          'Navigating to quest with ID from opened app: ${message.data['questId']}');
      AppRouter.router.go(AppConstants.activeQuestRoute);
    }
  });

  // ======================================================================
  // 10. INITIALIZE AND START FLUTTER BACKGROUND SERVICE
  // ======================================================================
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart:
          onStart, // The top-level function that runs in the background Isolate
      autoStart:
          false, // Set to false initially, start manually when needed (e.g., after login)
      isForegroundMode:
          true, // Essential for continuous tasks like location tracking
      notificationChannelId:
          'background_service_channel', // Android 8.0+ required
      notificationTitle: 'Campus Pulse Service',
      notificationContent: 'Running in background',
      initialNotificationTitle: 'Campus Pulse Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId:
          888, // Unique ID for the foreground notification
    ),
    iosConfiguration: IosConfiguration(
      onStart:
          onStart, // The top-level function that runs in the background Isolate
      autoStart: false, // Set to false initially
      onForeground:
          onStart, // For iOS, onStart is called for both foreground and background
      onBackground:
          onStart, // For iOS, onStart is called for both foreground and background
      autoStartEvent: 'autoStart', // Custom event to trigger auto-start on iOS
    ),
  );

  // You can start the service here if it should always run (e.g., for leaderboard updates)
  // Or start it conditionally (e.g., when a user logs in, or a specific quest type starts)
  // await service.start(); // This would start it immediately on app launch.
  // For now, we'll keep it commented out, assuming you'll start it conditionally.

  // ======================================================================
  // 11. RIVERPOD PROVIDER SCOPE AND APP RUN
  // ======================================================================
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ========================================================================
// 12. MYAPP WIDGET - Root of your UI
// ========================================================================
class MyApp extends ConsumerWidget {
  static final GoRouter router = AppRouter().router;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    ref.read(authProvider.notifier).checkInitialAuthStatus();

    return MaterialApp.router(
      routerConfig: MyApp.router,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
