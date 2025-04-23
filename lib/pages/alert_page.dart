import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriority = 'All';
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

  void toggleReadStatus(String docId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('alert')
        .doc(docId)
        .update({'read': !currentStatus});
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} ${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed completely
      body: Column(
        children: [
          // Removed SizedBox for 30px height
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search alerts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: ['All', 'High', 'Normal', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Filter by Priority',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('alert')
                  .where('active', isEqualTo: true)
                  .orderBy('date_time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No active alerts.'));
                }

                final alerts = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final priority = data['priority']?.toString() ?? '';
                  final matchesSearch = title.contains(_searchQuery);
                  final matchesPriority = _selectedPriority == 'All' ||
                      priority == _selectedPriority;
                  return matchesSearch && matchesPriority;
                }).toList();

                if (alerts.isEmpty) {
                  return const Center(
                      child: Text('No alerts match the filters.'));
                }

                return ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    final data = alert.data();
                    final title = data['title'] ?? 'No title';
                    final description = data['description'] ?? 'No description';
                    final priority = data['priority'] ?? 'Unknown';
                    final timestamp = data['date_time'] as Timestamp?;
                    final isRead = data['read'] == true;

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
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium,
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getPriorityColor(priority),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        priority,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isRead
                                            ? Icons.mark_email_unread
                                            : Icons.mark_email_read,
                                        color:
                                            isRead ? Colors.grey : Colors.green,
                                      ),
                                      tooltip: isRead
                                          ? 'Mark as Unread'
                                          : 'Mark as Read',
                                      onPressed: () =>
                                          toggleReadStatus(alert.id, isRead),
                                    ),
                                  ],
                                )
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
