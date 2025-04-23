import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

// Import the global navigatorKey
import '../main.dart'; // <-- Import main.dart to access navigatorKey

class NewAlertController extends GetxController {
  final RxInt alertCount = 0.obs;
  late final StreamSubscription _alertSubscription;
  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _initializePushNotifications();
    _listenToUnreadAlerts();
  }

  // Initialize Firebase Messaging and Local Notifications
  void _initializePushNotifications() async {
    // Initialize Firebase Messaging
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission for iOS devices (if applicable)
    await _firebaseMessaging.requestPermission();

    // Initialize local notifications plugin
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize notification plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Use the global navigator key to navigate
        final payload = response.payload;
        if (payload != null && payload.contains('navigate=alert')) {
          navigatorKey.currentState
              ?.pushNamed('/AlertPage'); // Use navigatorKey here
        }
      },
    );

    // Handle background and terminated state
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground message
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // Subscribe to the topic 'alerts' when initialized
    await _subscribeToAlertsTopic();

    // Handle app opened from a notification tap (background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final navigate = message.data['navigate'];
      if (navigate == 'alert') {
        navigatorKey.currentState
            ?.pushNamed('/AlertPage'); // Use navigatorKey here
      }
    });

    // Handle terminated state by checking initial message
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.data['navigate'] == 'alert') {
        navigatorKey.currentState
            ?.pushNamed('/AlertPage'); // Use navigatorKey here
      }
    });
  }

  // Subscribe to the Firebase topic 'alerts'
  Future<void> _subscribeToAlertsTopic() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('alerts');
      logger.i("Successfully subscribed to 'alerts' topic.");
    } catch (e) {
      logger.e("Error subscribing to 'alerts' topic: $e");
    }
  }

  // Background message handler (called when app is in background or terminated)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    logger.i("Handling a background message: ${message.messageId}");
  }

  // Handle foreground message and show local notifications
  void _onMessageReceived(RemoteMessage message) async {
    logger.i("Message received: ${message.notification?.title}");

    // Show a local notification when a new message arrives
    _showLocalNotification(message);
  }

  // Show a local notification using flutter_local_notifications
  void _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'alert_channel_id',
      'Alert Notifications',
      channelDescription: 'Notifications for new alerts',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: 'navigate=alert', // Add this to indicate navigation
    );
  }

  // Listen to Firestore changes for unread alerts
  void _listenToUnreadAlerts() {
    _alertSubscription = FirebaseFirestore.instance
        .collection('alert')
        .where('active', isEqualTo: true)
        .snapshots()
        .listen(
      (snapshot) {
        final unreadAlerts = snapshot.docs.where((doc) {
          final data = doc.data();
          return data['read'] != true;
        }).toList();

        alertCount.value = unreadAlerts.length;
      },
      onError: (error) {
        logger.e("Error fetching alerts: $error");
      },
    );
  }

  // Dispose the stream subscription when the controller is destroyed
  @override
  void onClose() {
    super.onClose();
    _alertSubscription.cancel();
  }

  // Increase the count manually
  void increaseCount() {
    alertCount.value++;
  }

  // Decrease the count manually
  void decreaseCount() {
    if (alertCount.value > 0) {
      alertCount.value--;
    }
  }

  // Reset the count to a specific value
  void resetCount(int newCount) {
    alertCount.value = newCount;
  }
}
