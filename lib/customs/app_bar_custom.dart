import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = false,
    this.showReload = false,
    this.onReload,
  });

  final String title;
  final bool showNotification;
  final bool showReload;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: title == Constant.appName ? false : true,
      leading: title == Constant.appName
          ? null
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: Theme.of(context).textTheme.bodySmall?.fontSize,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: true,
      actions: [
        if (showNotification)
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
              size: 5.w,
            ),
          ),
        if (showReload)
          IconButton(
            onPressed: onReload,
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 5.w,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
