import 'package:flutter/material.dart';

class BottomNavigationBarModel {
  final IconData selectedIcon;
  final IconData unSelectedIcon;
  final String label;
  final Widget page;

  const BottomNavigationBarModel({
    required this.selectedIcon,
    required this.unSelectedIcon,
    required this.label,
    required this.page,
  });
}
