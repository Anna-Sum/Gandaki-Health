import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../dashboard/add_alert_page.dart';
import '../dashboard/add_hospital_page.dart';
import '../dashboard/add_new_content_page.dart';
import '../dashboard/add_web_page.dart';
import '../dashboard/dashboard_page.dart';
import '../dashboard/feedback_page.dart';
import '../dashboard/add_statistics_page.dart';
import '../login/login_page.dart';
import '../login/sign_up_page.dart';
import '../login/forgot.dart';
import '../pages/bottom_navigation_bar/bottom_navigation_bar.dart';
// import '../pages/chatbot_page.dart';
import '../pages/content_page.dart';
import '../pages/home_page.dart';
import '../pages/hospital_list_page.dart';
import '../pages/profile_page.dart';
import '../pages/search_page.dart';
import '../pages/splash_page.dart';
import '../pages/web_view_page.dart';
import '../pages/userfeedback.dart';
import '../pages/alert_page.dart';

// Route names for navigation
class RouteNames {
  static const String splashPage = '/splashPage';
  static const String bottomNavigationBar = '/MyBottomNavigationBar';
  static const String homePage = '/MyHomePage';
  static const String searchPage = '/SearchPage';
  static const String contentPage = '/MyContentPage';
  static const String profilePage = '/MyProfilePage';
  static const String loginPage = '/MyLoginPage';
  static const String signUpPage = '/MySignUpPage';
  static const String forgotPasswordPage = '/ForgotPasswordPage';
  static const String myDashBoardPage = '/MyDashBoardPage';
  static const String alertAddPage = '/AlertAddPage';
  static const String addNewContentPage = '/AddNewContentPage';
  static const String feedbackPage = '/FeedbackPage';
  static const String webViewPage = '/MyWebListPage';
  static const String addWebLinkPage = '/AddWebLinkPage';
  static const String addHospitalPage = '/AddHospitalPage';
  static const String hospitalListPage = '/HospitalListPage';
  static const String feedbackListPage = '/FeedbackListPage';
  static const String alertPage = '/AlertPage';
  static const String addStatisticsPage = '/AddStatisticsPage';
  static const String chatbotPage = '/chatbotPage';
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashPage:
        return MaterialPageRoute(builder: (context) => MySplashPage());
      case RouteNames.bottomNavigationBar:
        return MaterialPageRoute(builder: (context) => MyBottomNavigationBar());
      case RouteNames.homePage:
        return MaterialPageRoute(builder: (context) => MyHomePage());
      case RouteNames.searchPage:
        return MaterialPageRoute(builder: (context) => MySearchPage());
      case RouteNames.contentPage:
        return MaterialPageRoute(builder: (context) => MyContentPage());
      case RouteNames.profilePage:
        return MaterialPageRoute(builder: (context) => MyProfilePage());
      case RouteNames.loginPage:
        return MaterialPageRoute(builder: (context) => MyLoginPage());
      case RouteNames.signUpPage:
        return MaterialPageRoute(builder: (context) => MySignUpPage());
      case RouteNames.forgotPasswordPage:
        return MaterialPageRoute(builder: (context) => ForgotPasswordPage());
      case RouteNames.webViewPage:
        return MaterialPageRoute(builder: (context) => MyWebListPage());
      case RouteNames.alertPage:
        return MaterialPageRoute(builder: (context) => AlertPage());
      case RouteNames.myDashBoardPage:
        return MaterialPageRoute(builder: (context) => MyDashBoardPage());
      case RouteNames.alertAddPage:
        return MaterialPageRoute(builder: (context) => AlertAddPage());
      case RouteNames.addNewContentPage:
        return MaterialPageRoute(builder: (context) => AddNewContentPage());
      case RouteNames.addWebLinkPage:
        return MaterialPageRoute(builder: (context) => AddWebLinkPage());
      case RouteNames.feedbackPage:
        return MaterialPageRoute(builder: (context) => FeedbackPage());
      case RouteNames.addHospitalPage:
        return MaterialPageRoute(builder: (context) => AddHospitalPage());
      case RouteNames.addStatisticsPage:
        return MaterialPageRoute(builder: (context) => AddStatisticsPage());
      // case RouteNames.chatbotPage:
      //   return MaterialPageRoute(builder: (context) => ChatbotPage());
      case RouteNames.feedbackListPage:
        return MaterialPageRoute(builder: (context) => FeedbackListPage());
      case RouteNames.hospitalListPage:
        return MaterialPageRoute(builder: (context) => HospitalListPage());
      default:
        return MaterialPageRoute(builder: (context) {
          return UndefinedWidget();
        });
    }
  }
}

class UndefinedWidget extends StatefulWidget {
  const UndefinedWidget({super.key});

  @override
  State<UndefinedWidget> createState() => _UndefinedWidgetState();
}

class _UndefinedWidgetState extends State<UndefinedWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(
          const Duration(seconds: 2),
          () {
            if (mounted) _controller.forward(from: 0.0);
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.8,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Lottie.asset(
                  'assets/animation/under-construction.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),
              const Text('Screen Might be under Progress'),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Go Back'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      );
}
