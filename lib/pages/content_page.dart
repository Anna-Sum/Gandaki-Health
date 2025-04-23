import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyContentPage extends StatefulWidget {
  static const routeName = '/ContentPage';

  const MyContentPage({super.key});

  @override
  State<MyContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<MyContentPage> {
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

  void _launchURL(String mediaUrl) async {
    final Uri url = Uri.parse(mediaUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $mediaUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> contentQuery = FirebaseFirestore.instance
        .collection('content')
        .where('active', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(50); // Optional: increase limit for better filtering

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search content...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['All', 'Infographics', 'Audio', 'Video']
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
              stream: contentQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No content available.'));
                }

                final contentList = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final description =
                      data['description']?.toString().toLowerCase() ?? '';
                  final category = data['category']?.toString() ?? '';

                  final matchesSearch = title.contains(_searchQuery) ||
                      description.contains(_searchQuery);
                  final matchesCategory = _selectedCategory == 'All' ||
                      category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (contentList.isEmpty) {
                  return const Center(
                      child: Text('No content matches the filters.'));
                }

                return ListView.builder(
                  itemCount: contentList.length,
                  itemBuilder: (context, index) {
                    final content = contentList[index];
                    final data = content.data();
                    final title = data['title'] ?? 'No Title';
                    final description = data['description'] ?? 'No Description';
                    final category = data['category'] ?? 'Uncategorized';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final mediaUrl = data['mediaUrl'] ?? '';

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
                            GestureDetector(
                              onTap: () {
                                if (mediaUrl.isNotEmpty) {
                                  _launchURL(mediaUrl);
                                }
                              },
                              child: Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            if (mediaUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _launchURL(mediaUrl);
                                },
                                child: const Text(
                                  'Open Media',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
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
                                      .labelMedium
                                      ?.copyWith(color: Colors.grey),
                                ),
                                Chip(
                                  label: Text(category),
                                  backgroundColor: Colors.blueAccent,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
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
