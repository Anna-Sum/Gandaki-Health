import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../customs/app_bar_custom.dart';

// Admin Feedback Management Page
class FeedbackListPage extends StatelessWidget {
  static const routeName = '/FeedbackListPage';

  const FeedbackListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedbackListView();
  }
}

class FeedbackListView extends StatefulWidget {
  const FeedbackListView({super.key});

  @override
  FeedbackListViewState createState() => FeedbackListViewState();
}

class FeedbackListViewState extends State<FeedbackListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getFeedbackStream() {
    return _firestore
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete feedback: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'User Feedbacks'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFeedbackStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No feedback available.'));
          }

          final feedbackDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedback = feedbackDocs[index];
              final feedbackId = feedback.id;
              final feedbackData = feedback.data() as Map<String, dynamic>;

              // Getting user initials (or username if no avatar)
              String initials = feedbackData['name'] != null
                  ? feedbackData['name']![0].toUpperCase()
                  : 'A';

              final String feedbackType =
                  feedbackData['feedback_type'] ?? 'Unknown';
              final int rating = feedbackData['rating'] ?? 0;
              final Timestamp timestamp = feedbackData['timestamp'];
              final dateTime = timestamp.toDate();
              final formattedDate =
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      initials,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    feedbackData['name'] ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Feedback Type: $feedbackType'),
                      const SizedBox(height: 4),
                      Text('Submitted on: $formattedDate'),
                      const SizedBox(height: 8),
                      Text(feedbackData['feedback'] ?? 'No feedback provided.'),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.yellow[700],
                          );
                        }),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFeedback(feedbackId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
