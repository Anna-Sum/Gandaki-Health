import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

Widget _buildDiseaseCarousel() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('diseaseStats')
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading stats'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No active disease stats'));
      }

      final items = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final disease = data['disease'] ?? 'Unknown';
        final count = data['count'] ?? 0;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color.fromARGB(255, 239, 120, 109),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                const Icon(Icons.coronavirus, color: Colors.white, size: 60),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$count reported cases',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList();

      return CarouselSlider(
        items: items,
        options: CarouselOptions(
          height: 14.h,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
        ),
      );
    },
  );
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
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
              width: widget.size * (1 + _animation.value * 0.0),
              height: widget.size * (1 + _animation.value * 0.0),
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

class MyHomePage extends StatefulWidget {
  static const routeName = '/MyHomePage';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<QuerySnapshot> fetchRecentAlerts() {
    return FirebaseFirestore.instance
        .collection('alert')
        .where('active', isEqualTo: true)
        .orderBy('date_time', descending: true)
        .limit(3)
        .snapshots();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 1.h),

              _buildDiseaseCarousel(),
              SizedBox(height: 1.h),

              // Emergency Services
              Card(
                color: const Color.fromARGB(255, 249, 222, 222),
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
                                              fontSize: 14.sp,
                                              color: Colors.red)),
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
                                        size: 10.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text('Ambulance',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text('102',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.red)),
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
              SizedBox(height: 1.h),

              // Additional Services Section with Navigation Icons
              Card(
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Additional Services',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/MyWebListPage');
                              },
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        color: Colors.deepPurple,
                                        size: 8.w,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text('Web Links',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/FeedbackPage');
                              },
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.feedback,
                                        color: Colors.deepPurple,
                                        size: 8.w,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text('Feedback',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/chatbotPage');
                              },
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        color: Colors.deepPurple,
                                        size: 8.w,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text('Assistant',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold)),
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
              SizedBox(height: 1.h),

              // Recent Alerts
              _buildAlertList(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertList() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Recent Alerts',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: fetchRecentAlerts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  log("Error fetching alerts: ${snapshot.error}");
                  return Center(child: Text("Error fetching alerts"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No recent alerts found"));
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return CustomAlertTile(
                      title: data['title'] ?? 'No Title',
                      description: data['description'],
                      status: data['priority'] ?? 'Unknown',
                      dateTime: formatTimestamp(data['date_time']),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      );
}

class CustomAlertTile extends StatelessWidget {
  const CustomAlertTile({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.dateTime,
  });

  final String title;
  final String description;
  final String status;
  final String dateTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x2F2195F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[800],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateTime,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'High':
        return Colors.red;
      case 'Normal':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
