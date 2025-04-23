import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart'; // Ensure GetX is imported
import '../pages/alert_page.dart';

// Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permissions for iOS
    await _firebaseMessaging.requestPermission();

    // Handle messages while app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });

    // Handle messages in background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications setup
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // This will navigate to the AlertPage using GetX when the user taps on a notification
        Get.to(() => AlertPage());
      },
    );
  }

  // Background handler for Firebase Cloud Messaging
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    developer.log("Handling a background message: ${message.messageId}");
    await FirebaseMessagingService()._showLocalNotification(message);
  }

  // Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      developer.log("Subscribed to topic: $topic");
    } catch (e) {
      developer.log("Error subscribing to topic: $e");
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alert_channel_id',
      'Alert Notifications',
      channelDescription:
          'Shows alert notifications for both foreground and background',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      platformDetails,
    );
  }
}
