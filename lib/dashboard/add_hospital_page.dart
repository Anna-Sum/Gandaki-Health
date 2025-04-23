import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddHospitalPage extends StatefulWidget {
  static const routeName = '/AddHospitalPage';
  const AddHospitalPage({super.key});

  @override
  State<AddHospitalPage> createState() => _AddHospitalPageState();
}

class _AddHospitalPageState extends State<AddHospitalPage> {
  final _formKey = GlobalKey<FormState>();

  final _hospitalNameController = TextEditingController();
  final _superintendentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

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

  final List<String> _resourceTypes = [
    'Private Hospital',
    'Province Hospital',
    'Ayurveda Hospital',
    'Province Public Health Office',
  ];

  String? _selectedDistrict;
  String? _selectedResourceType;
  bool _showForm = false;
  String? _editingHospitalId;

  final CollectionReference hospitals =
      FirebaseFirestore.instance.collection('hospitals');

  Future<void> _addHospital() async {
    if (_formKey.currentState!.validate() &&
        _selectedDistrict != null &&
        _selectedResourceType != null) {
      try {
        await hospitals.add({
          'hospitalName': _hospitalNameController.text,
          'superintendent': _superintendentController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'district': _selectedDistrict,
          'resourceType': _selectedResourceType,
          'website': _websiteController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'isActive': false, // Added field for active status
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hospital added successfully')),
          );
        }

        _clearForm();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding hospital: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
    }
  }

  Future<void> _editHospital() async {
    if (_formKey.currentState!.validate() &&
        _selectedDistrict != null &&
        _selectedResourceType != null) {
      try {
        await hospitals.doc(_editingHospitalId).update({
          'hospitalName': _hospitalNameController.text,
          'superintendent': _superintendentController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'district': _selectedDistrict,
          'resourceType': _selectedResourceType,
          'website': _websiteController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hospital updated successfully')),
          );
        }

        _clearForm();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating hospital: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
    }
  }

  void _clearForm() {
    _hospitalNameController.clear();
    _superintendentController.clear();
    _phoneController.clear();
    _emailController.clear();
    _websiteController.clear();

    setState(() {
      _selectedDistrict = null;
      _selectedResourceType = null;
      _showForm = false;
      _editingHospitalId = null;
    });
  }

  Future<void> _toggleActiveStatus(
      String hospitalId, bool currentStatus) async {
    try {
      await hospitals.doc(hospitalId).update({'isActive': !currentStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _deleteHospital(String hospitalId) async {
    try {
      await hospitals.doc(hospitalId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting hospital: $e')),
        );
      }
    }
  }

  Future<void> _loadHospitalData(String hospitalId) async {
    try {
      final hospital = await hospitals.doc(hospitalId).get();
      final data = hospital.data() as Map<String, dynamic>;

      _hospitalNameController.text = data['hospitalName'];
      _superintendentController.text = data['superintendent'];
      _phoneController.text = data['phone'];
      _emailController.text = data['email'];
      _websiteController.text = data['website'];
      _selectedDistrict = data['district'];
      _selectedResourceType = data['resourceType'];

      setState(() {
        _editingHospitalId = hospitalId;
        _showForm = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading hospital data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _superintendentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() => _showForm = true);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _showForm
                ? Expanded(
                    child: SingleChildScrollView(
                      // Add SingleChildScrollView here
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ...[
                              // Form Fields
                              TextFormField(
                                controller: _hospitalNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Hospital Name'),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter hospital name'
                                    : null,
                              ),
                              TextFormField(
                                controller: _superintendentController,
                                decoration: const InputDecoration(
                                    labelText: 'Superintendent'),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter superintendent'
                                    : null,
                              ),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                    labelText: 'Phone Number'),
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty
                                    ? 'Enter phone number'
                                    : null,
                              ),
                              TextFormField(
                                controller: _emailController,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Enter valid email';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _websiteController,
                                decoration: const InputDecoration(
                                    labelText: 'Website URL'),
                                keyboardType: TextInputType.url,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      !Uri.tryParse(value)!.isAbsolute) {
                                    return 'Enter valid URL';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedDistrict,
                                hint: const Text('Select District'),
                                items: _districts.map((district) {
                                  return DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedDistrict = val);
                                },
                                validator: (value) =>
                                    value == null ? 'Select a district' : null,
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedResourceType,
                                hint: const Text('Select Resource Type'),
                                items: _resourceTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedResourceType = val);
                                },
                                validator: (value) => value == null
                                    ? 'Select a resource type'
                                    : null,
                              ),
                            ].map((widget) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: widget,
                                )),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _editingHospitalId == null
                                        ? _addHospital
                                        : _editHospital,
                                    child: Text(_editingHospitalId == null
                                        ? 'Submit'
                                        : 'Update'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showForm = false;
                                      _formKey.currentState?.reset();
                                    });
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
                    ),
                  )
                : Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: hospitals.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final hospitalsList = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: hospitalsList.length,
                          itemBuilder: (context, index) {
                            final hospital = hospitalsList[index];
                            final hospitalId = hospital.id;
                            final hospitalName = hospital['hospitalName'];
                            final isActive = hospital['isActive'];
                            final district = hospital['district'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 12.0),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  title: Text(
                                    hospitalName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'District: $district',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isActive
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        onPressed: () {
                                          _toggleActiveStatus(
                                              hospitalId, isActive);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          _loadHospitalData(hospitalId);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _deleteHospital(hospitalId);
                                        },
                                      ),
                                    ],
                                  ),
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
