import 'dart:convert';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

// =================== Providers ===================

final dialysisStatsProvider =
    StateNotifierProvider<DialysisStatsNotifier, Map<String, dynamic>>((ref) {
  return DialysisStatsNotifier();
});

class DialysisStatsNotifier extends StateNotifier<Map<String, dynamic>> {
  DialysisStatsNotifier() : super({}) {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dialysis.gandakidata.com/api/getDialysisStatisticData'));

      if (response.statusCode == 200) {
        state = json.decode(response.body);
      } else {
        log('Failed to fetch data');
      }
    } catch (e) {
      log('Error: $e');
    }
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredDialysisStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final data = ref.watch(dialysisStatsProvider);

  if (query.isEmpty) return data;

  return Map.fromEntries(
    data.entries.where((entry) => entry.key.toLowerCase().contains(query)),
  );
});

final diseaseStatsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('diseaseStats')
      .where('isActive', isEqualTo: true)
      .orderBy('timestamp', descending: true)
      .snapshots();
});

// =================== Page ===================
class MySearchPage extends ConsumerWidget {
  static const routeName = '/MySearchPage';
  const MySearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(filteredDialysisStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ========== Disease Statistics Carousel ==========

              // =================== Disease Statistics UI Using GridView ===================

              Consumer(
                builder: (context, ref, _) {
                  final asyncSnapshot = ref.watch(diseaseStatsStreamProvider);

                  return asyncSnapshot.when(
                    data: (snapshot) {
                      final docs = snapshot.docs;
                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('No disease statistics available.'),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Text(
                              'Province Disease Statistics',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Using GridView for displaying disease stats
                          GridView.builder(
                            shrinkWrap:
                                true, // To make the GridView take only necessary space
                            physics:
                                NeverScrollableScrollPhysics(), // Disable scrolling of GridView inside a scrollable parent
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two columns
                              crossAxisSpacing: 16.0, // Space between columns
                              mainAxisSpacing: 16.0, // Space between rows
                              childAspectRatio:
                                  1.5, // Adjusting the aspect ratio of each grid item
                            ),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final name = data['disease'] ?? 'Unknown';
                              final count = data['count'] ?? 0;

                              return StatCard(
                                title: name,
                                value: 'Cases: $count',
                              );
                            },
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Error loading disease stats: $e'),
                    ),
                  );
                },
              ),

              // ========== Hemodialysis Statistics Title ==========
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Province Hemodialysis Statistics',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // ========== Dialysis Stats Carousel ==========
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: stats.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : CarouselSlider(
                        items: [
                          StatCard(
                            title: 'Total Hospital',
                            value: '${stats['total_hospital'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Dialysis Units',
                            value: '${stats['dialysis_unit'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total Machine',
                            value: '${stats['total_machine'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Active Machine',
                            value: '${stats['active_machine'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Damaged Machine',
                            value: '${stats['damaged_machine'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Operational Dialysis Bed',
                            value: '${stats['operational_dialysis_bed'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total Nephrologist',
                            value: '${stats['total_nephrologist'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total MDGP',
                            value: '${stats['total_mdgp'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total Medical Officer',
                            value: '${stats['total_medical_officer'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total Staff Nurse',
                            value: '${stats['total_staff_nurse'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total Biomedical Technician',
                            value:
                                '${stats['total_biomedical_technician'] ?? 0}',
                          ),
                          StatCard(
                            title: 'Total Helper',
                            value: '${stats['total_helper'] ?? 0}',
                          ),
                        ],
                        options: CarouselOptions(
                          height: 160,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          viewportFraction: 0.75,
                          aspectRatio: 3.0,
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

// =================== Shared Widget ===================

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
