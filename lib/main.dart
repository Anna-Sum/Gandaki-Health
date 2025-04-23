import 'dart:developer' as devtools show log;
import 'controllers/new_alert_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'firebase_services/firebase_initialization.dart';
import 'firebase_services/firebase_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'customs/theme_custom.dart';
import 'pages/profile_page.dart';
import 'route_manager/route_manager.dart';

// Define a GlobalKey for Navigator (Global Navigator Key)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  devtools.log('Initializing app...');
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Firebase is fully initialized before continuing
  await MyFirebaseInitialization.firebaseInitialization();

  // Subscribe to Firebase alerts topic
  await FirebaseMessagingService.subscribeToTopic('alerts');

  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Initialize GetX Controller for alert badge
  Get.put(NewAlertController());

  // Handle notification tap (background & terminated)
  handleNotificationNavigation();

  devtools.log('Running app...');
  runApp(ProviderScope(child: MyApp()));
}

// Notification tap handler function
void handleNotificationNavigation() {
  // When app is opened from background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    devtools.log("Notification tapped - background state");
    final data = message.data;
    if (data['navigate'] == 'alert') {
      // Navigate to Alert Page using GetX
      Get.toNamed(RouteNames.alertPage);
    }
  });

  // When app is opened from terminated state
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null && message.data['navigate'] == 'alert') {
      devtools.log("Notification tapped - terminated state");
      // Navigate to Alert Page using GetX
      Get.toNamed(RouteNames.alertPage);
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    devtools.log('Building app...');
    final themeMode = ref.watch(themeProvider);

    return Sizer(builder: (context, orientation, deviceType) {
      devtools.log('Configuring GetMaterialApp...');
      return GetMaterialApp(
        // Use GetMaterialApp for GetX integration
        debugShowCheckedModeBanner: false,
        theme: MyAppTheme.lightTheme,
        darkTheme: MyAppTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: RouteNames.splashPage,
        onGenerateRoute: RouteGenerator.getRoute,
        // Add navigatorKey for background and terminated notifications
        navigatorKey:
            navigatorKey, // This is defined globally in your main.dart
      );
    });
  }
}
