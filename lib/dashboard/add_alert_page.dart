import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import '../customs/app_bar_custom.dart';

class AlertAddPage extends StatefulWidget {
  static const routeName = '/AlertAddPage';
  const AlertAddPage({super.key});

  @override
  State<AlertAddPage> createState() => _MyAlertAddPageState();
}

class _MyAlertAddPageState extends State<AlertAddPage> {
  bool repeatAlert = false;
  String priority = 'Normal';
  List<String> priorityLevels = ['Low', 'Normal', 'High'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeController.text = pickedTime.format(context);
      });
    }
  }

  void _saveAlertToFirestore() async {
    if (titleController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    try {
      DateTime selectedDate = DateTime.parse(dateController.text);
      List<String> timeParts = timeController.text.split(' ');
      List<String> hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      int minute = int.parse(hourMin[1]);

      if (timeParts[1] == "PM" && hour != 12) {
        hour += 12;
      } else if (timeParts[1] == "AM" && hour == 12) {
        hour = 0;
      }

      DateTime fullDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
        minute,
      );

      await FirebaseFirestore.instance.collection('alert').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'date_time': Timestamp.fromDate(fullDateTime),
        'priority': priority,
        'repeat': repeatAlert,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alert added successfully!")),
        );
      }

      titleController.clear();
      descriptionController.clear();
      dateController.clear();
      timeController.clear();
      setState(() {
        repeatAlert = false;
        priority = 'Normal';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding alert: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Add Alert'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Alert',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Alert Title',
                      hintText: 'Enter alert title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alert Description',
                      hintText: 'Enter alert description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: IgnorePointer(
                            child: TextField(
                              controller: dateController,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                hintText: 'Select date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          child: IgnorePointer(
                            child: TextField(
                              controller: timeController,
                              decoration: InputDecoration(
                                labelText: 'Time',
                                hintText: 'Select time',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: const Icon(Icons.access_time),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Checkbox(
                        value: repeatAlert,
                        onChanged: (bool? value) {
                          setState(() {
                            repeatAlert = value ?? false;
                          });
                        },
                      ),
                      Text('Repeat Alert', style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    value: priority,
                    items: priorityLevels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        priority = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Priority Level',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _saveAlertToFirestore,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Add Alert',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
