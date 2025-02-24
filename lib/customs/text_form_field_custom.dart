import 'package:flutter/material.dart';

import '../constants/constant.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.controller,
    this.obscureText = false,
  });

  final String? hintText;
  final Widget? prefixIcon, suffixIcon;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: MyAppColors.primaryColor.withAlpha(20),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        prefixIcon: prefixIcon,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
