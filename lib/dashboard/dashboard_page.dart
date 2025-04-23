import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../customs/app_bar_custom.dart';
import '../route_manager/route_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              width: widget.size * (1 + _animation.value * 0),
              height: widget.size * (1 + _animation.value * 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color
                    .withAlpha(((0.5 * (1 - _animation.value)) * 255).toInt()),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _getTotalAlerts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('alert')
        .where('active', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalUsers() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getGeneralUsers(String s) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('userType', isEqualTo: 'general')
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getHealthcareProviders(String s) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('userType', isEqualTo: 'healthcare')
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalIECs(String s) async {
    QuerySnapshot snapshot = await _firestore
        .collection('content')
        .where('active', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalFeedbacks(String category) async {
    QuerySnapshot snapshot = await _firestore
        .collection('feedback')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
      ),
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
                    'Admin',
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://storage.googleapis.com/a1aa/image/TEU0hSkeW66tdxpWkzLrwtUdAax10DrV2PEskFnNwwU.jpg',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Total Alerts and Total Users
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Alerts',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.add_alert_sharp,
                                    color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<int>(
                              future: _getTotalAlerts(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error!',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold));
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Users',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.group, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<int>(
                              future: _getTotalUsers(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error!',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold));
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // General Users and Healthcare Providers
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'General Users',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.person, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<int>(
                              future: _getGeneralUsers('general'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error!',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold));
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
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Healthcare Providers',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.local_hospital,
                                    color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<int>(
                              future: _getHealthcareProviders('healthcare'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error!',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold));
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
//Total feedback and Total IECs
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total IECs',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.book, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<int>(
                              future: _getTotalIECs('true'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error!',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold));
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Feedbacks',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.feedback, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<int>(
                              future: _getTotalFeedbacks('health_portal'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error!',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold));
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Emergency Services
              Card(
                color: const Color.fromARGB(255, 247, 196, 206),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Emergency Services',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
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
                                      // Keep the BlinkingIcon widget for animation
                                      BlinkingIcon(
                                        icon: Icons.medical_services,
                                        color: Colors.red,
                                        size: 10.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text('Hello Doctor',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text('1092',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600])),
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
                                      // Keep the BlinkingIcon widget for animation
                                      BlinkingIcon(
                                        icon: Icons.local_hospital,
                                        color: Colors.red,
                                        size: 10.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text('Ambulance',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text('102',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600])),
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

              // Quick Actions
              Card(
                color: const Color.fromARGB(255, 212, 237, 248),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center the content
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                        textAlign: TextAlign.center, // Center the text itself
                      ),
                      SizedBox(height: 1.h),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        mainAxisSpacing: 2.h,
                        crossAxisSpacing: 2.w,
                        physics: const NeverScrollableScrollPhysics(),
                        children: quickActionItems.map((action) {
                          return QuickActionCard(
                            icon: action.icon,
                            label: action.label,
                          );
                        }).toList(),
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
          padding: EdgeInsets.all(2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: colors[quickActionItems
                    .indexWhere((element) => element.label == label)],
                size: 5.w,
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
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
    label: 'New IECs',
    icon: Icons.file_copy,
    routeName: RouteNames.addNewContentPage,
  ),
  QuickActionModel(
    label: 'Add Resources',
    icon: Icons.local_hospital,
    routeName: RouteNames.addHospitalPage,
  ),
];
