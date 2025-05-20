import 'package:firebase_messaging/firebase_messaging.dart';
// Note: FlutterLocalNotificationsPlugin is managed in main.dart for global display

// ========================================================================
// NOTIFICATION SERVICE
// Provides methods to interact with Firebase Messaging (e.g., get FCM token).
// The main FCM initialization and listeners are handled in main.dart.
// ========================================================================
class NotificationService {
  final FirebaseMessaging _firebaseMessaging;

  NotificationService({required FirebaseMessaging firebaseMessaging})
      : _firebaseMessaging = firebaseMessaging;

  /// Returns the FCM token for the device.
  /// This token should be sent to your backend to enable targeted notifications.
  Future<String?> getFCMToken() async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      print("NotificationService: Retrieved FCM Token: $fcmToken");
      return fcmToken;
    } catch (e) {
      print("NotificationService: Error getting FCM token: $e");
      return null;
    }
  }

  // You can add other methods here if needed, e.g.:
  // Future<void> subscribeToTopic(String topic) async {
  //   await _firebaseMessaging.subscribeToTopic(topic);
  // }
  //
  // Future<void> unsubscribeFromTopic(String topic) async {
  //   await _firebaseMessaging.unsubscribeFromTopic(topic);
  // }
}

// The top-level background message handler should remain in main.dart
// as it needs to be accessible by the Flutter engine directly.
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // ... (This function is in main.dart)
// }
