import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddHospitalPage extends StatefulWidget {
  static const routeName = '/AddHospitalPage';
  const AddHospitalPage({super.key});

  @override
  State<AddHospitalPage> createState() => _AddHospitalPageState();
}

class _AddHospitalPageState extends State<AddHospitalPage> {
  final _hospitalNameController = TextEditingController();
  final _superintendentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final List<String> _districts = [
    'Baglung',
    'Gorkha',
    'Kaski',
    'Lamjung',
    'Manang',
    'Mustang',
    'Myagdi',
    'Nawalpur',
    'Parbat',
    'Syangja',
    'Tanahun',
  ];
  String? _selectedDistrict;

  final CollectionReference hospitals =
      FirebaseFirestore.instance.collection('hospitals');

  final _formKey = GlobalKey<FormState>();

  Future<void> _addHospital() async {
    if (_formKey.currentState!.validate() && _selectedDistrict != null) {
      try {
        await hospitals.add({
          'hospitalName': _hospitalNameController.text,
          'superintendent': _superintendentController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'district': _selectedDistrict,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _hospitalNameController.clear();
        _superintendentController.clear();
        _phoneController.clear();
        _emailController.clear();
        setState(() {
          _selectedDistrict = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hospital added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding hospital: $e')),
          );
        }
      }
    } else if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a district')),
      );
    }
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _superintendentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hospital'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: MediaQuery.of(context).size.height * 0.02,
              children: [
                TextFormField(
                  controller: _hospitalNameController,
                  decoration: const InputDecoration(labelText: 'Hospital Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hospital name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _superintendentController,
                  decoration: const InputDecoration(
                      labelText: 'Medical Superintendent'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter superintendent name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  hint: const Text('Select District'),
                  items: _districts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDistrict = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a district' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addHospital,
                  child: const Text('Add Hospital'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
