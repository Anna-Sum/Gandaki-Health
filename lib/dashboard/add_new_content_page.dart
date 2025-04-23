import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewContentPage extends StatefulWidget {
  final DocumentSnapshot? contentData;

  const AddNewContentPage({super.key, this.contentData});

  @override
  State<AddNewContentPage> createState() => _AddNewContentPageState();
}

class _AddNewContentPageState extends State<AddNewContentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mediaUrlController = TextEditingController();
  String _selectedCategory = 'Infographics';
  bool _isLoading = false;
  bool _isActive = false;
  bool _isExpanded = false; // Controls the expansion of the form

  @override
  void initState() {
    super.initState();
    if (widget.contentData != null) {
      _titleController.text = widget.contentData!['title'];
      _descriptionController.text = widget.contentData!['description'];
      _mediaUrlController.text = widget.contentData!['mediaUrl'];
      _selectedCategory = widget.contentData!['category'] ?? 'Infographics';
      _isActive = widget.contentData!['active'] ?? false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  Future<void> saveContent() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final mediaUrl = _mediaUrlController.text.trim();

    // Validate input
    if (title.isEmpty || description.isEmpty || mediaUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Check for valid media URL
    if (!Uri.parse(mediaUrl).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = false;

    try {
      final now = DateTime.now();
      final contentData = {
        'title': title,
        'description': description,
        'mediaUrl': mediaUrl,
        'category': _selectedCategory,
        'active': _isActive,
        'timestamp': FieldValue.serverTimestamp(),
        'date_time': Timestamp.fromDate(now),
      };

      if (widget.contentData != null) {
        await FirebaseFirestore.instance
            .collection('content')
            .doc(widget.contentData!.id)
            .update(contentData);
      } else {
        await FirebaseFirestore.instance.collection('content').add(contentData);
      }

      success = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save content')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _titleController.clear();
          _descriptionController.clear();
          _mediaUrlController.clear();
          _selectedCategory = 'Infographics';
          _isActive = false;
        }
      }
    }
  }

  Future<void> deleteContent(String id) async {
    await FirebaseFirestore.instance.collection('content').doc(id).delete();
  }

  Future<void> toggleContentActive(String id, bool currentStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('content')
          .doc(id)
          .update({'active': !currentStatus}); // Toggle active status
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update visibility')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contentData != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IECs Management'),
        actions: [
          // "+" button to show the form
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded; // Toggle form expansion
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show the form only when expanded
            if (_isExpanded || isEditing)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration:
                            const InputDecoration(labelText: 'Content Title'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _mediaUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Media URL (Video/Audio/Infographic)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: ['Infographics', 'Audio', 'Video']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: saveContent,
                                  child: Text(isEditing
                                      ? 'Update Content'
                                      : 'Add Content'),
                                ),
                          ElevatedButton(
                            onPressed: () {
                              if (widget.contentData != null) {
                                // If editing, navigate back to the previous screen
                                Navigator.pop(context);
                              } else {
                                // If adding a new content, collapse the form
                                setState(() {
                                  _isExpanded = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                    ],
                  ),
                ),
              ),
            // Show the list of content when the form is not expanded
            if (!_isExpanded && !isEditing)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('content')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final contents = snapshot.data!.docs;

                    if (contents.isEmpty) {
                      return const Center(child: Text('No content found.'));
                    }

                    return ListView.builder(
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        final content = contents[index];
                        final data = content.data() as Map<String, dynamic>;
                        final isActive = data['active'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              data['title'],
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make the title bold
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['description']),
                                Text("Category: ${data['category']}"),
                                Text("URL: ${data['mediaUrl']}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddNewContentPage(
                                          contentData: content,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => deleteContent(content.id),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isActive
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: isActive ? Colors.green : Colors.red,
                                  ),
                                  tooltip: isActive
                                      ? 'Visible (Tap to hide)'
                                      : 'Hidden (Tap to show)',
                                  onPressed: () {
                                    toggleContentActive(content.id, isActive);
                                  },
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
