import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

import 'customs/theme_custom.dart';
import 'firebase_services/firebase_initialization.dart';
import 'pages/profile_page.dart';
import 'route_manager/route_manager.dart';

void main() async {
  devtools.log('Initializing app...');
  WidgetsFlutterBinding.ensureInitialized();
  MyFirebaseInitialization.firebaseInitialization();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  devtools.log('Running app...');
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    devtools.log('Building app...');
    final themeMode = ref.watch(themeProvider);
    return Sizer(builder: (context, orientation, deviceType) {
      devtools.log('Configuring material app...');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MyAppTheme.lightTheme,
        darkTheme: MyAppTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: RouteNames.splashPage,
        onGenerateRoute: RouteGenerator.getRoute,
      );
    });
  }
}
