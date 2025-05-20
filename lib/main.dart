import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod's ProviderScope
import 'package:go_router/go_router.dart'; // Import GoRouter

// Firebase imports for FCM
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For foreground notifications

// Your existing project imports
import 'core/navigation/app_router.dart'; // Your AppRouter
import 'presentation/providers/auth_provider.dart'; // Your Riverpod AuthProvider
import 'presentation/providers/leaderboard_provider.dart'; // Your Riverpod LeaderboardProvider
import 'presentation/providers/profile_provider.dart'; // Your Riverpod ProfileProvider
import 'presentation/providers/quest_provider.dart'; // Your Riverpod QuestProvider
import 'core/theme/theme_provider.dart'; // Your Riverpod ThemeProvider
import 'core/theme/app_theme.dart'; // Your AppTheme for light/dark themes
import 'core/constants/app_constants.dart'; // To use app routes

// ========================================================================
// 1. TOP-LEVEL FUNCTION FOR FCM BACKGROUND MESSAGES
// This function must be a top-level function (not inside a class)
// and marked with @pragma('vm:entry-point') for Flutter to find it.
// It runs when a message is received while the app is in the background or terminated.
// ========================================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background message handling
  await Firebase.initializeApp();
  print("Background Message Handled: ${message.messageId}");
  print("Background Message Data: ${message.data}");

  // TODO: Implement logic here to process background quest notifications.
  // For example, save the quest data to a local database for later retrieval,
  // or trigger a local notification to alert the user.
  // This is where you would process `message.data` to extract quest info.
  // If the message contains a quest, you might want to save its ID or details
  // so that when the app is opened from the notification, the ActiveQuestScreen
  // can load the correct quest.
}

// ========================================================================
// 2. GLOBAL INSTANCE FOR FLUTTER LOCAL NOTIFICATIONS
// This plugin is used to display notifications when the app is in the foreground.
// ========================================================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ========================================================================
// 3. MAIN FUNCTION - Entry point of the Flutter application
// ========================================================================
void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase App
  await Firebase.initializeApp();

  // Set up the background message handler for FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ======================================================================
  // 4. INITIALIZE FLUTTER LOCAL NOTIFICATIONS PLUGIN
  // This configures how local notifications behave on different platforms.
  // ======================================================================
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Use your app's icon

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Logic for handling iOS local notifications when app is in foreground
      // (This is for older iOS versions, on newer ones onDidReceiveNotificationResponse is used)
      print('iOS Local Notification (Foreground): $title, $body, $payload');
      // You might want to handle navigation here for older iOS versions
      // if the payload contains navigation data.
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  // Initialize the plugin with the settings
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // This callback is triggered when a notification (local or from FCM handled locally)
      // is tapped by the user, regardless of app state (foreground, background, terminated).
      print('Notification Response Payload: ${response.payload}');
      if (response.payload != null && response.payload!.isNotEmpty) {
        // If the payload contains a questId, navigate to the active quest screen
        // We use the static router instance from AppRouter for navigation.
        print('Navigating to quest with ID from payload: ${response.payload}');
        // Assuming the payload is the questId, navigate to the active quest route
        // and potentially pass the questId as a parameter if your ActiveQuestScreen
        // is set up to receive it. For this example, we'll just navigate to the screen.
        // A more robust implementation would pass the ID and the screen would load it.
        AppRouter.router.go(AppConstants.activeQuestRoute);
      }
    },
  );

  // ======================================================================
  // 5. REQUEST NOTIFICATION PERMISSIONS (iOS & Android 13+)
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
  // 6. GET FCM TOKEN AND SEND TO YOUR BACKEND
  // This token identifies the specific device for sending targeted notifications.
  // ======================================================================
  String? fcmToken = await messaging.getToken();
  print("FCM Device Token: $fcmToken");
  // TODO: Send this `fcmToken` to your application's backend.
  // Associate it with the currently logged-in user so that your backend
  // can send specific quest notifications to that user's device.
  // This typically involves an API call from your AuthProvider or a dedicated UserService.

  // ======================================================================
  // 7. LISTEN FOR FCM MESSAGES WHEN APP IS IN FOREGROUND
  // ======================================================================
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('FCM Message Received in Foreground!');
    print('Message data: ${message.data}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If there's a notification part, display it as a local notification.
    // This makes sure the user sees a visual alert even if the app is open.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode, // Unique ID for the notification
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'quest_channel', // Android Channel ID (must be unique)
            'Quest Notifications', // Android Channel Name (user visible)
            channelDescription: 'Notifications for new and active quests',
            icon: android.smallIcon, // Icon shown in status bar
            importance: Importance.high, // Make it a high-priority notification
            priority: Priority.high,
            // You can add sound, vibrate patterns etc. here
          ),
        ),
        // Pass data (like questId) as payload so it's available on tap
        payload: message.data['questId'],
      );
    }
    // TODO: If the user is currently on the ActiveQuestScreen and this notification
    // is about a new quest, you might want to trigger a state update in the
    // QuestProvider to load the new quest immediately without requiring a tap.
    // This would involve accessing the QuestProvider instance here.
    // This is where Riverpod's `container` could be used if you need to access providers
    // from a non-widget context, but typically this logic goes into a service or provider.
  });

  // ======================================================================
  // 8. LISTEN FOR FCM MESSAGES WHEN APP IS OPENED FROM NOTIFICATION TAP
  // This listener is called when a user taps on a notification that brought
  // the app from background/terminated state to foreground.
  // ======================================================================
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('FCM Message opened app from background/terminated state!');
    print('Notification Data: ${message.data}');
    // This is the primary place to navigate the user to the relevant screen,
    // e.g., the ActiveQuestScreen, using `message.data` to get the quest ID.
    if (message.data['questId'] != null) {
      print(
          'Navigating to quest with ID from opened app: ${message.data['questId']}');
      // Navigate to the active quest route.
      // If your ActiveQuestScreen expects a questId parameter in the route,
      // you would pass it here, e.g., AppRouter.router.go('${AppConstants.activeQuestRoute}/${message.data['questId']}');
      AppRouter.router.go(AppConstants.activeQuestRoute);
    }
  });

  // ======================================================================
  // 9. RIVERPOD PROVIDER SCOPE AND APP RUN
  // ======================================================================
  runApp(
    const ProviderScope(
      // Replaced MultiProvider with ProviderScope
      child: MyApp(), // Your root widget
    ),
  );
}

// ========================================================================
// 10. MYAPP WIDGET - Root of your UI (Now a ConsumerWidget to watch theme)
// ========================================================================
class MyApp extends ConsumerWidget {
  // Changed to ConsumerWidget
  // It's good practice to make the router accessible, perhaps via a static instance
  // or by passing it down if dynamic navigation is needed from outside widgets.
  // For GoRouter, often AppRouter itself is designed to be accessible.
  // Making it static here to allow access from FCM listeners in main.dart
  static final GoRouter router = AppRouter().router; // Made router static

  const MyApp({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    // Watch the themeMode from the Riverpod themeProvider
    final themeMode = ref.watch(themeModeProvider);

    // Initialize AuthProvider's initial status check once the app starts
    // This is a good place to do it, as it's part of the app's initial setup.
    // Use ref.read to call the notifier method, as we don't need to rebuild MyApp
    // when the AuthProvider state changes.
    ref.read(authProvider.notifier).checkInitialAuthStatus();

    return MaterialApp.router(
      routerConfig: MyApp.router, // Use the static router
      title: AppConstants.appName,
      theme: AppTheme.lightTheme, // Use the light theme
      darkTheme: AppTheme.darkTheme, // Use the dark theme
      themeMode: themeMode, // Set theme mode based on Riverpod ThemeProvider
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}
