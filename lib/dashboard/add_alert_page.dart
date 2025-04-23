import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlertAddPage extends StatefulWidget {
  final DocumentSnapshot? alertData;

  const AlertAddPage({super.key, this.alertData});

  @override
  State<AlertAddPage> createState() => _AlertAddPageState();
}

class _AlertAddPageState extends State<AlertAddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _priority = 'Normal';
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _isEditing = false;
  String? _editingAlertId;

  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotification();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.d("Foreground message: ${message.notification?.title}");
      _showLocalNotification(message.notification?.title ?? 'Alert',
          message.notification?.body ?? '');
    });
  }

  void _initializeNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _showLocalNotification(String title, String description) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alert_channel_id',
      'Alert Notifications',
      channelDescription: 'Shows alert notifications while app is foreground',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      description,
      platformDetails,
    );
  }

  void _populateFormForEdit(DocumentSnapshot alert) {
    final data = alert.data() as Map<String, dynamic>;
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _priority = data['priority'] ?? 'Normal';
    _editingAlertId = alert.id;
    setState(() {
      _isEditing = true;
      _isExpanded = true;
    });
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priority = 'Normal';
    _editingAlertId = null;
    _isEditing = false;
  }

  Future<void> saveAlert() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnackbar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    bool success = false;

    try {
      final now = DateTime.now();
      final alertData = {
        'title': title,
        'description': description,
        'priority': _priority,
        'active': true,
        'date_time': Timestamp.fromDate(now),
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      if (_isEditing && _editingAlertId != null) {
        await FirebaseFirestore.instance
            .collection('alert')
            .doc(_editingAlertId)
            .update(alertData);
      } else {
        await FirebaseFirestore.instance.collection('alert').add(alertData);
      }

      await sendPushNotification(title, description);
      await _showLocalNotification(title, description);
      success = true;
    } catch (e) {
      _logger.e("Error saving alert: $e");
      _showSnackbar('Failed to save alert');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _onSuccessClearForm();
        }
      }
    }
  }

  Future<void> sendPushNotification(String title, String description) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('alerts');
      _logger.d("Subscribed to alerts topic.");
      _logger.d("Simulated push notification to topic: $title");
    } catch (e) {
      _logger.e("Error sending push notification: $e");
    }
  }

  Future<void> deleteAlert(String id) async {
    await FirebaseFirestore.instance.collection('alert').doc(id).delete();
  }

  Future<void> toggleAlertActive(String id, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('alert')
        .doc(id)
        .update({'active': !currentStatus});
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onSuccessClearForm() {
    _clearForm();
    setState(() => _isExpanded = false);
    _showSnackbar(
        _isEditing ? 'Alert successfully updated' : 'Alert successfully added');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts Management'),
        actions: [
          IconButton(
            icon: Icon(_isExpanded ? Icons.close : Icons.add),
            onPressed: () {
              setState(() {
                if (_isExpanded) {
                  _clearForm();
                }
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isExpanded) _buildAlertForm(),
            if (!_isExpanded) _buildAlertList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertForm() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Alert Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              onChanged: (val) => setState(() => _priority = val!),
              decoration: const InputDecoration(labelText: 'Priority'),
              items: ['High', 'Normal', 'Low']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: saveAlert,
                        child: Text(_isEditing ? 'Update Alert' : 'Add Alert'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _clearForm();
                          setState(() => _isExpanded = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alert')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!.docs;
          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts found.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final data = alert.data() as Map<String, dynamic>;
              final isActive = data['active'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    data['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] ?? ''),
                      Text("Priority: ${data['priority']}"),
                      Text(
                          "Date: ${data['date_time']?.toDate() ?? DateTime.now()}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _populateFormForEdit(alert),
                      ),
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.visibility : Icons.visibility_off,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                        tooltip: isActive
                            ? 'Active - Tap to disable'
                            : 'Inactive - Tap to enable',
                        onPressed: () => toggleAlertActive(alert.id, isActive),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Alert',
                        onPressed: () => deleteAlert(alert.id),
                      ),
                    ],
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
