import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
      {super.key, required this.title, this.showNotification = false});

  final String title;
  final bool showNotification;

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
                size: 5.w,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: showNotification
          ? [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 5.w,
                  )),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
