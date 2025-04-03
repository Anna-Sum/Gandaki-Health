import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../customs/app_bar_custom.dart';
import '../fire.dart';
import '../route_manager/route_manager.dart';

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    throw 'Could not launch $phoneNumber';
  }
}

class BlinkingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const BlinkingIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<BlinkingIcon> createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<BlinkingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.size * (1 + _animation.value * 0.5),
              height: widget.size * (1 + _animation.value * 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: widget.color.withOpacity(0.3 * (1 - _animation.value)),
                color: widget.color.withValues(alpha: 0.3 * (1 - _animation.value)),
              ),
            );
          },
        ),
        Icon(widget.icon, color: widget.color, size: widget.size),
      ],
    );
  }
}

class MyDashBoardPage extends StatefulWidget {
  static const routeName = RouteNames.myDashBoardPage;
  const MyDashBoardPage({super.key});

  @override
  State<MyDashBoardPage> createState() => _MyDashBoardPageState();
}

class _MyDashBoardPageState extends State<MyDashBoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Dashboard'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 2.w),
                  Text(
                    'Admin Dashboard',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://storage.googleapis.com/a1aa/image/TEU0hSkeW66tdxpWkzLrwtUdAax10DrV2PEskFnNwwU.jpg',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Alerts',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.add_alert_sharp,
                                    color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            StreamBuilder<int>(
                              stream: myFirebase.countAlertStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error!',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data == 0
                                        ? '...'
                                        : '${snapshot.data}',
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Users',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.group, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            StreamBuilder<int>(
                              stream: myFirebase.countUserStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error!',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data == 0
                                        ? '...'
                                        : '${snapshot.data}',
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Services',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _makePhoneCall('1092'),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Column(
                                    children: [
                                      BlinkingIcon(
                                        icon: Icons.medical_services,
                                        color: Colors.red,
                                        size: 6.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Hello Doctor',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '1092',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: InkWell(
                              onTap: () => _makePhoneCall('102'),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Column(
                                    children: [
                                      BlinkingIcon(
                                        icon: Icons.local_hospital,
                                        color: Colors.red,
                                        size: 6.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Ambulance',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '102',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: quickActionItems.map((action) {
                          return QuickActionCard(
                            icon: action.icon,
                            label: action.label,
                          );
                        }).toList(
                          growable: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
                Icon(icon, color: color),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickActionCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.cyan,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.yellow,
    ];
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
            context,
            quickActionItems
                .firstWhere((element) => element.label == label)
                .routeName);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: colors[quickActionItems.indexOf(quickActionItems
                    .firstWhere((element) => element.label == label))],
                size: 5.w,
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionModel {
  final String label;
  final IconData icon;
  final String routeName;

  QuickActionModel({
    required this.label,
    required this.icon,
    required this.routeName,
  });
}

List<QuickActionModel> quickActionItems = [
  QuickActionModel(
    label: 'New Alert',
    icon: Icons.add,
    routeName: RouteNames.alertAddPage,
  ),
  QuickActionModel(
    label: 'New Content',
    icon: Icons.file_copy,
    routeName: RouteNames.addNewContentPage,
  ),
  QuickActionModel(
    label: 'Add Video',
    icon: Icons.play_circle_filled_outlined,
    routeName: RouteNames.addVideoPage,
  ),
  QuickActionModel(
    label: 'Feedback',
    icon: Icons.feedback,
    routeName: RouteNames.feedbackPage,
  ),
  QuickActionModel(
    label: 'Add Web Link',
    icon: Icons.language,
    routeName: RouteNames.addWebLinkPage,
  ),
  QuickActionModel(
    label: 'Add Hospitals',
    icon: Icons.local_hospital,
    routeName: RouteNames.addHospitalPage,
  ),
];
