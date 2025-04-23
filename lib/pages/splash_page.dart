import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';
import '../route_manager/route_manager.dart';

class MySplashPage extends ConsumerStatefulWidget {
  static const routeName = '/MySplashPage';
  const MySplashPage({super.key});

  @override
  ConsumerState<MySplashPage> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends ConsumerState<MySplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool stayHere = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward().whenComplete(() {
      stayHere
          ? _controller.repeat()
          : Navigator.pushNamed(context, RouteNames.loginPage);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    'assets/splash_screen/emblem.png',
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildGradientText(
                  colors: [
                    Colors.white.withAlpha(80),
                    Colors.white,
                    Colors.white.withAlpha(80),
                  ],
                  child: Text(
                    'Gandaki Health Alert',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [
                        FontFeature.enable('smcp'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 11.h,
            left: 10.w,
            right: 10.w,
            child: Center(
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFeatures: [
                    FontFeature.enable('smcp'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 10.w,
            right: 10.w,
            child: _buildLinearProgressIndicator(),
          ),
        ],
      ),
    );
  }

  LinearProgressIndicator _buildLinearProgressIndicator() {
    return LinearProgressIndicator(
      value: _controller.value,
      minHeight: 0.6.h,
      backgroundColor: Colors.white,
      valueColor: AlwaysStoppedAnimation<Color>(MyAppColors.primaryColor),
    );
  }

  ShaderMask _buildGradientText({
    required Widget? child,
    required List<Color> colors,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(bounds),
      child: child,
    );
  }
}
