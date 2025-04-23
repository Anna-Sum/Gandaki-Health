import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/firebase_constant.dart';

class AddStatisticsPage extends StatefulWidget {
  final DocumentSnapshot? contentData;

  const AddStatisticsPage({super.key, this.contentData});

  @override
  State<AddStatisticsPage> createState() => _AddStatisticsPageState();
}

class _AddStatisticsPageState extends State<AddStatisticsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  final CollectionReference diseaseStats =
      FirebaseFirestore.instance.collection(FirebaseCollection.diseaseStats);

  bool _isExpanded = false;
  String? _editingId;

  Future<void> _addOrUpdateDisease() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'disease': _nameController.text.trim(),
          'count': int.parse(_countController.text.trim()),
          'timestamp': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        if (_editingId != null) {
          await diseaseStats.doc(_editingId).update(data);
        } else {
          await diseaseStats.add(data);
        }

        _clearForm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_editingId == null
                  ? 'Disease added successfully!'
                  : 'Disease updated successfully!'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _countController.clear();
    setState(() {
      _editingId = null;
      _isExpanded = false;
    });
  }

  Future<void> _deleteDisease(String id) async {
    await diseaseStats.doc(id).delete();
  }

  Future<void> _toggleIsActive(String id, bool currentStatus) async {
    await diseaseStats.doc(id).update({'isActive': !currentStatus});
  }

  void _editDisease(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _nameController.text = data['disease'] ?? '';
      _countController.text = data['count'].toString();
      _editingId = doc.id;
      _isExpanded = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Management'),
        actions: [
          IconButton(
            icon: Icon(_isExpanded ? Icons.close : Icons.add),
            tooltip: _isExpanded ? 'Close Form' : 'Add New',
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (!_isExpanded) {
                  _clearForm();
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingId == null ? 'Add New Disease' : 'Edit Disease',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Disease Name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter disease name'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _countController,
                            decoration: const InputDecoration(
                              labelText: 'Count',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter count';
                              }
                              final count = int.tryParse(value.trim());
                              if (count == null || count < 0) {
                                return 'Enter a valid positive number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addOrUpdateDisease,
                                child: Text(_editingId == null
                                    ? 'Add Disease'
                                    : 'Update'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _clearForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                      ],
                    ),
                  )
                ],
              ),

            // Disease List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: diseaseStats
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No records found.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isActive = data['isActive'] ?? true;

                      return Card(
                        child: ListTile(
                          title: Text(data['disease'] ?? 'No disease'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Count: ${data['count'] ?? '0'}"),
                              Text(
                                "Status: ${isActive ? 'Visible' : 'Hidden'}",
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editDisease(doc),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDisease(doc.id),
                              ),
                              IconButton(
                                icon: Icon(
                                  isActive
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isActive ? Colors.green : Colors.grey,
                                ),
                                onPressed: () =>
                                    _toggleIsActive(doc.id, isActive),
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
      ),
    );
  }
}
