import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/firebase_constant.dart';

class AddWebLinkPage extends StatefulWidget {
  final DocumentSnapshot? contentData;

  const AddWebLinkPage({super.key, this.contentData});

  @override
  State<AddWebLinkPage> createState() => _WebsiteFormState();
}

class _WebsiteFormState extends State<AddWebLinkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  final CollectionReference websites =
      FirebaseFirestore.instance.collection(FirebaseCollection.websites);

  bool _isExpanded = false;
  String? _editingId;

  Future<void> _addOrUpdateWebsite() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'title': _titleController.text.trim(),
          'link': _linkController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        if (_editingId != null) {
          await websites.doc(_editingId).update(data);
        } else {
          await websites.add(data);
        }

        _clearForm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_editingId == null
                  ? 'Website added successfully!'
                  : 'Website updated successfully!'),
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
    _titleController.clear();
    _linkController.clear();
    setState(() {
      _editingId = null;
      _isExpanded = false;
    });
  }

  Future<void> _deleteWebsite(String id) async {
    await websites.doc(id).delete();
  }

  Future<void> _toggleIsActive(String id, bool currentStatus) async {
    await websites.doc(id).update({'isActive': !currentStatus});
  }

  void _editWebsite(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _linkController.text = data['link'] ?? '';
      _editingId = doc.id;
      _isExpanded = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weblinks Management'),
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
                    _editingId == null ? 'Add New Weblink' : 'Edit Weblink',
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
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter title'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _linkController,
                            decoration: const InputDecoration(
                              labelText: 'Link',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                            validator: (value) {
                              final url = value?.trim() ?? '';
                              if (url.isEmpty) return 'Enter link';
                              if (!url.startsWith('http')) {
                                return 'Must start with http:// or https://';
                              }
                              final uri = Uri.tryParse(url);
                              if (uri == null || !uri.isAbsolute) {
                                return 'Please enter a valid URL';
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
                                onPressed: _addOrUpdateWebsite,
                                child: Text(_editingId == null
                                    ? 'Add Weblink'
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

            // Website List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    websites.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No websites found.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isActive = data['isActive'] ?? true;

                      return Card(
                        child: ListTile(
                          title: Text(data['title'] ?? 'No Title'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['link'] ?? ''),
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
                                onPressed: () => _editWebsite(doc),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteWebsite(doc.id),
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
