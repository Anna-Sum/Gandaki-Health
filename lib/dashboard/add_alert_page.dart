import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MyAlertAddPage extends StatefulWidget {
  const MyAlertAddPage({super.key});

  @override
  State<MyAlertAddPage> createState() => _MyAlertAddPageState();
}

class _MyAlertAddPageState extends State<MyAlertAddPage> {
  bool repeatAlert = false;
  String priority = 'Normal';
  List<String> priorityLevels = ['Low', 'Normal', 'High'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  void _showAlertDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Alert Details', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${titleController.text}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              Text('Description: ${descriptionController.text}', style: TextStyle(fontSize: 12.sp)),
              SizedBox(height: 1.h),
              Text('Date: ${dateController.text}', style: TextStyle(fontSize: 12.sp)),
              Text('Time: ${timeController.text}', style: TextStyle(fontSize: 12.sp)),
              Text('Priority: $priority', style: TextStyle(fontSize: 12.sp)),
              Text('Repeat: ${repeatAlert ? "Yes" : "No"}', style: TextStyle(fontSize: 12.sp)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
      ),
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
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                        child: TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Select date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          decoration: InputDecoration(
                            labelText: 'Time',
                            hintText: 'Select time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: Icon(Icons.access_time),
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
                      onPressed: _showAlertDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Add Alert',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
