import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';
import '../http_services/dialysis_statistic_data_model.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/MyHomePage';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<DialysisStatisticDataModel> fetchDialysisData() async {
    final response = await http.get(
      Uri.parse(
          'https://dialysis.gandakidata.com/api/getDialysisStatisticData'),
    );

    if (response.statusCode == 200) {
      return DialysisStatisticDataModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Stream<QuerySnapshot> fetchRecentAlerts() {
    return FirebaseFirestore.instance
        .collection('alert')
        .orderBy('date_time', descending: true)
        .limit(5)
        .snapshots();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<DialysisStatisticDataModel>(
            future: fetchDialysisData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return Center(child: Text("No Data Available"));
              } else {
                final data = snapshot.data!;
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyCarouselSlider(
                        items: [
                          _buildItem(
                            title: 'Total Hospitals',
                            number: data.totalHospital,
                          ),
                          _buildItem(
                            title: 'Dialysis Units',
                            number: data.dialysisUnit,
                          ),
                          _buildItem(
                            title: 'Total Machine',
                            number: data.totalMachine,
                          ),
                          _buildItem(
                            title: 'Active Machine',
                            number: data.activeMachine,
                          ),
                          _buildItem(
                            title: 'Damaged Machine',
                            number: data.damagedMachine,
                          ),
                          _buildItem(
                            title: 'Operational Dialysis Bed',
                            number: data.operationalDialysisBed,
                          ),
                          _buildItem(
                            title: 'Total Nephrologist',
                            number: data.totalNephrologist,
                          ),
                          _buildItem(
                            title: 'Total MDGP',
                            number: data.totalMdgp,
                          ),
                          _buildItem(
                            title: 'Total Medical Officer',
                            number: data.totalMedicalOfficer,
                          ),
                          _buildItem(
                            title: 'Total Staff Nurse',
                            number: data.totalStaffNurse,
                          ),
                          _buildItem(
                            title: 'Total Biomedical Technician',
                            number: data.totalBiomedicalTechnician,
                          ),
                          _buildItem(
                            title: 'Total Helper',
                            number: data.totalHelper,
                          ),
                          _buildItem(
                            title: 'Trained MDGP',
                            number: data.trainedMdgp,
                          ),
                          _buildItem(
                            title: 'Trained Medical Officer',
                            number: data.trainedMedicalOfficer,
                          ),
                          _buildItem(
                            title: 'Trained Staff Nurse',
                            number: data.trainedStaffNurse,
                          ),
                          _buildItem(
                            title: 'Trained Biomedical Technician',
                            number: data.trainedBiomedicalTechnician,
                          ),
                          _buildItem(
                            title: 'Trained Helper',
                            number: data.trainedHelper,
                          ),
                          _buildItem(
                            title: 'Waiting Patient',
                            number: data.waitingPatient,
                          ),
                          _buildItem(
                            title: 'Active Patient',
                            number: data.activePatient,
                          ),
                          _buildItem(
                            title: 'Registered Patient',
                            number: data.registeredPatient,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 1.h),
          _buildAlertList(),
        ],
      ),
    );
  }

  Widget _buildAlertList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Recent Alerts',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
                log("No data found in Firestore");
                return Center(child: Text("No recent alerts found"));
              }

              for (var doc in snapshot.data!.docs) {
                log("Fetched Alert: ${doc.data()}");
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return CustomAlertTile(
                      title: data['title'] ?? 'No Title',
                      description: data['description'],
                      status: data['priority'] ?? 'Unknown',
                      dateTime: formatTimestamp(data['date_time']));
                }).toList(),
              );
            },
          ),
        ],
      );

  SizedBox _buildItem({required String title, required int number}) {
    return SizedBox(
      height: double.infinity,
      width: 50.w,
      child: Card(
        elevation: 2.h,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '$number',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MyAppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyCarouselSlider extends StatelessWidget {
  const MyCarouselSlider({super.key, this.items});

  final List<Widget>? items;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: items,
      options: CarouselOptions(
        viewportFraction: 0.7,
        aspectRatio: 3.5,
        autoPlay: true,
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
      onTap: () {},
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x2F2195F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 1.w,
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
                          fontWeight: FontWeight.bold,
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
    switch (status.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'normal':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
