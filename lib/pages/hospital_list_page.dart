import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalListPage extends StatefulWidget {
  static const routeName = '/HospitalListPage';

  const HospitalListPage({super.key});

  @override
  State<HospitalListPage> createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} ${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  Future<void> _callPhone(String phoneNumber) async {
    if (!_isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number')),
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        if (!mounted) return;
        await launchUrl(launchUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place a call')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(emailUri)) {
        if (!mounted) return;
        await launchUrl(emailUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchWebsite(String website) async {
    final Uri websiteUri = Uri.parse(website);
    try {
      if (await canLaunchUrl(websiteUri)) {
        if (!mounted) return;
        await launchUrl(websiteUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> hospitalQuery = FirebaseFirestore.instance
        .collection('hospitals')
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(50);

    if (_selectedCategory != 'All') {
      hospitalQuery =
          hospitalQuery.where('resourceType', isEqualTo: _selectedCategory);
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search hospitals...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: [
                'All',
                'Private Hospital',
                'Province Hospital',
                'Aayurved Hospital',
                'Province Public Health Office'
              ]
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: hospitalQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hospitals available.'));
                }

                final hospitalList = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final name =
                      data['hospitalName']?.toString().toLowerCase() ?? '';
                  final type =
                      data['resourceType']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery) ||
                      type.contains(_searchQuery);
                }).toList();

                if (hospitalList.isEmpty) {
                  return const Center(
                      child: Text('No hospitals match the filters.'));
                }

                return ListView.builder(
                  itemCount: hospitalList.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitalList[index];
                    final data = hospital.data();
                    final name = data['hospitalName'] ?? '';
                    final type = data['resourceType'] ?? '';
                    final district = data['district'] ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final superintendent = data['superintendent'] ?? '';
                    final phoneNumber = data['phone'] ?? '';
                    final email = data['email'] ?? '';
                    final website = data['website'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Type: $type'),
                            Text('District: $district'),
                            Text('Superintendent: $superintendent'),
                            const SizedBox(height: 8),
                            Text('Phone: $phoneNumber'),
                            GestureDetector(
                              onTap: () => _launchEmail(email),
                              child: Text(
                                email,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _launchWebsite(website),
                              child: Text(
                                website,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatTimestamp(timestamp),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                Chip(
                                  label: Text(type),
                                  backgroundColor: Colors.blueAccent,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.phone),
                                  onPressed: () => _callPhone(phoneNumber),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
