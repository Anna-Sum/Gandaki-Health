import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../fire.dart';

class MyDashBoardPage extends StatefulWidget {
  const MyDashBoardPage({super.key});

  @override
  State<MyDashBoardPage> createState() => _MyDashBoardPageState();
}

class _MyDashBoardPageState extends State<MyDashBoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //
              Row(
                children: [
                  Icon(Icons.heart_broken),
                  SizedBox(width: 2.w),
                  Text('HealthAdmin'),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  IconButton(
                      onPressed: () {
                        myFirebase.registerUser(
                          "admin@example.com",
                          "password123",
                          "John Doe",
                        );
                      },
                      icon: Icon(Icons.notifications)),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://storage.googleapis.com/a1aa/image/TEU0hSkeW66tdxpWkzLrwtUdAax10DrV2PEskFnNwwU.jpg',
                    ),
                  ),
                ],
              ),
              //
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
                                Text('Active Alerts'),
                                Icon(
                                  Icons.notifications,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              '24',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
                                Text('Total Users'),
                                Icon(
                                  Icons.group,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            StreamBuilder<int>(
                              stream: myFirebase.countUserStream(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data == 0
                                        ? '...'
                                        : '${snapshot.data}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return CircularProgressIndicator();
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
              SizedBox(height: 1.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          QuickActionCard(icon: Icons.add, label: 'New Alert'),
                          QuickActionCard(
                              icon: Icons.book, label: 'Add Resource'),
                          QuickActionCard(
                              icon: Icons.file_copy, label: 'New Content'),
                          QuickActionCard(
                              icon: Icons.feedback, label: 'Feedback'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'View All',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      RecentAlertCard(
                          title: 'COVID-19 Update',
                          time: 'Updated 2h ago',
                          status: 'Active'),
                      SizedBox(height: 16),
                      RecentAlertCard(
                          title: 'Air Quality Warning',
                          time: 'Updated 5h ago',
                          status: 'Active'),
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
    return InkWell(
      onTap: () {
        // Perform action
        Navigator.pushNamed(context, '/add_alert_page');
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blue, size: 8.w),
              SizedBox(height: 1.h),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentAlertCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;

  const RecentAlertCard(
      {super.key,
      required this.title,
      required this.time,
      required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.5.h),
            Text(
              time,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
