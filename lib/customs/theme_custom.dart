import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';

class MyAppTheme {
  //light theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: MyAppColors.primaryColor,
    scaffoldBackgroundColor: MyAppColors.scaffoldBackgroundColor,
    //AppBar
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: MyAppColors.primaryColor,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    //BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MyAppColors.primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 14.sp,
      ),
    ),
    //splash
    splashFactory: InkRipple.splashFactory,
    highlightColor: MyAppColors.primaryColor,
    //TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MyAppColors.primaryColor,
        // shape: const BeveledRectangleBorder(
        //   side: BorderSide(color: MyAppColors.primaryColor, width: 0.4),
        // ),
      ),
    ),
    //Input decoration for TextField and TextformField
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      // fillColor: MyAppColors.textFieldFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: MyAppColors.primaryColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: MyAppColors.primaryColor,
        ),
      ),
    ),
    //checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(MyAppColors.primaryColor),
      checkColor: WidgetStateProperty.all(MyAppColors.scaffoldBackgroundColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      side: const BorderSide(
        color: MyAppColors.primaryColor,
        width: 2.0,
      ),
    ),
    //ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyAppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    //ScaffoldMessenger
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MyAppColors.primaryColor,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14.sp,
      ),
    ),
    useMaterial3: true,
  );

  //dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: MyAppColors.darkPrimaryColor,
    scaffoldBackgroundColor: MyAppColors.scaffoldBackgroundColorDark,
    //AppBar
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: MyAppColors.appBackgroundColorDark,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    //BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MyAppColors.appBackgroundColorDark,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 14.sp,
      ),
    ),
    //splash
    splashFactory: InkRipple.splashFactory,
    highlightColor: MyAppColors.darkPrimaryColor,
    //TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MyAppColors.primaryColor,
        // shape: const BeveledRectangleBorder(
        //   side: BorderSide(color: MyAppColors.primaryColor, width: 0.4),
        // ),
      ),
    ),
    //Input decoration for TextField and TextformField
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      // fillColor: MyAppColors.textFieldFillColorDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: MyAppColors.primaryColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: MyAppColors.primaryColor,
        ),
      ),
    ),
    //checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(MyAppColors.primaryColor),
      checkColor:
          WidgetStateProperty.all(MyAppColors.scaffoldBackgroundColorDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      side: const BorderSide(
        color: MyAppColors.primaryColor,
        width: 2.0,
      ),
    ),
    //ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyAppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    //ScaffoldMessenger
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MyAppColors.primaryColor,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14.sp,
      ),
    ),
    useMaterial3: true,
  );
}
