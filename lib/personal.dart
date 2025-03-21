import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({Key? key}) : super(key: key);

  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  DateTime? _dob;
  DateTime? _doRecording;
  String _gender = 'Male';
  final _homeTownController = TextEditingController();
  final _regionController = TextEditingController();
  final _currentCityController = TextEditingController();
  final _durationController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  bool _adDiagnosis = false;

  bool _isFormSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _homeTownController.dispose();
    _regionController.dispose();
    _currentCityController.dispose();
    _durationController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context, bool isDoB) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isDoB ? (_dob ?? DateTime.now()) : (_doRecording ?? DateTime.now()),
      firstDate: isDoB ? DateTime(1900) : DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isDoB) {
          _dob = picked;
        } else {
          _doRecording = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_isFormSubmitted),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 60), // Space for header
                  // Name
                  _buildTextFormField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),

                  // Date of Birth
                  _buildDateField(
                    label: 'Date of Birth',
                    value: _dob,
                    icon: Icons.cake,
                    onTap: () => _selectDate(context, true),
                  ),

                  // Date of Recording
                  _buildDateField(
                    label: 'Date of Recording',
                    value: _doRecording,
                    icon: Icons.calendar_today,
                    onTap: () => _selectDate(context, false),
                  ),

                  // Gender
                  _buildGenderSelector(),

                  // Home Town
                  _buildTextFormField(
                    controller: _homeTownController,
                    label: 'Home Town',
                    icon: Icons.home,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter home town';
                      }
                      return null;
                    },
                  ),

                  // Home Town Region
                  _buildTextFormField(
                    controller: _regionController,
                    label: 'Home Town Region',
                    icon: Icons.map,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter region';
                      }
                      return null;
                    },
                  ),

                  // Current City
                  _buildTextFormField(
                    controller: _currentCityController,
                    label: 'Current City',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current city';
                      }
                      return null;
                    },
                  ),

                  // Duration of Stay
                  _buildTextFormField(
                    controller: _durationController,
                    label: 'Duration of Stay in City (years)',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter duration';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  // Place of Birth
                  _buildTextFormField(
                    controller: _birthPlaceController,
                    label: 'Place of Birth',
                    icon: Icons.child_care,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter place of birth';
                      }
                      return null;
                    },
                  ),

                  // AD Diagnosis
                  _buildSwitchField(
                    label: 'Alzheimer\'s Disease Diagnosis',
                    value: _adDiagnosis,
                    onChanged: (value) {
                      setState(() {
                        _adDiagnosis = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _dob != null &&
                            _doRecording != null) {
                          // Save data to shared preferences or database
                          _savePersonalInfo();

                          // Show success dialog
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Personal Information'),
                                  content: const Text(
                                    'Information saved successfully!',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isFormSubmitted = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                        } else {
                          // Show validation message for dates
                          if (_dob == null || _doRecording == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select both dates'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Submit Information',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Floating header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Patient Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save personal information
  Future<void> _savePersonalInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('personalInfoSubmitted', true);
    setState(() {
      _isFormSubmitted = true;
    });
  }

  // UI Components
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: Icon(icon),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(icon),
          ),
          child:
              value == null
                  ? const Text('Select date')
                  : Text(DateFormat('yyyy-MM-dd').format(value)),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.people),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _gender,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
              DropdownMenuItem(
                value: 'Prefer not to say',
                child: Text('Prefer not to say'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _gender = value;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.green),
        ],
      ),
    );
  }
}
