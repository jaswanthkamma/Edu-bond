import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  // Correctly define message as a named parameter
  const ProfilePage({Key? key, required this.username}) : super(key: key);
  //const SignupPage({super.key});
  //const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  String? _selectedEducation;
  String? _manualEducation;
  DateTime? _selectedDateOfBirth;
  List<String> _selectedCoursesToLearn = [];
  List<String> _selectedCoursesKnown = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;

  List<String> educationOptions = [
    'Graduate',
    'Undergraduate',
    'Diploma',
    'Certificate',
    'High School',
    'Other'
  ];

  List<String> courseOptions = [
    'C',
    'C++',
    'Python',
    'Flutter',
    'DSA',
    'Java',
    'JavaScript',
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Other',
  ];

  // Image picker function
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Validate if only letters are used for name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Only letters are allowed';
    }
    return null;
  }

  // Validate phone number
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  // Function to calculate age based on date of birth
  int _calculateAge(DateTime dateOfBirth) {
    DateTime today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Gender selection widget
  Widget _genderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender*',
          style: TextStyle(fontSize: 16),
        ),
        Row(
          children: ['Male', 'Female', 'Others']
              .map(
                (gender) => Row(
                  children: [
                    Radio<String>(
                      value: gender,
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    Text(gender),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // Education dropdown widget
  Widget _educationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Education Type'),
          value: _selectedEducation,
          items: educationOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedEducation = value;
              if (value != 'Other') {
                _manualEducation = null; // Reset manual input if not "Other"
              }
            });
          },
          validator: (value) =>
              value == null ? 'Please select an education type' : null,
        ),
        // Manual education input appears if "Other" is selected
        if (_selectedEducation == 'Other') ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Specify Education'),
            onChanged: (value) {
              setState(() {
                _manualEducation = value;
              });
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please specify your education'
                : null,
          ),
        ],
      ],
    );
  }

  // Date picker for date of birth
  Widget _dateOfBirthPicker() {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && _calculateAge(picked) >= 10) {
          setState(() {
            _selectedDateOfBirth = picked;
          });
        } else if (picked != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You must be at least 10 years old'),
          ));
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date of Birth*'),
        child: Text(
          _selectedDateOfBirth == null
              ? 'Select Date'
              : DateFormat('dd-MM-yyyy').format(_selectedDateOfBirth!),
        ),
      ),
    );
  }

  // Profile photo upload widget
  Widget _photoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo (optional)',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                _selectedImage != null ? FileImage(_selectedImage!) : null,
            child: _selectedImage == null
                ? const Icon(Icons.camera_alt, size: 30)
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Dropdown with checkboxes for courses to learn
  Widget _coursesToLearnDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '',
        ),
        GestureDetector(
          onTap: () {
            _showCoursesToLearnDialog();
          },
          child: InputDecorator(
            decoration: const InputDecoration(
                labelText: 'Select Courses to Learn*',
                hintStyle: TextStyle(fontSize: 16)),
            child: Text(
              _selectedCoursesToLearn.isNotEmpty
                  ? _selectedCoursesToLearn.join(', ')
                  : 'Select Courses',
            ),
          ),
        ),
        // Display selected courses
        if (_selectedCoursesToLearn.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected Courses to Learn: ${_selectedCoursesToLearn.join(', ')}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  void _showCoursesToLearnDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Courses to Learn'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: courseOptions.map((course) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: Text(course),
                      value: _selectedCoursesToLearn.contains(course),
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (!_selectedCoursesToLearn.contains(course)) {
                              _selectedCoursesToLearn.add(course);
                            }
                          } else {
                            _selectedCoursesToLearn.remove(course);
                          }
                        });
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {}); // Refresh parent widget
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  // Dropdown with checkboxes for courses known
  Widget _coursesKnownDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '',
        ),
        GestureDetector(
          onTap: () {
            _showCoursesKnownDialog();
          },
          child: InputDecorator(
            decoration: const InputDecoration(
                labelText: 'Select Courses You Know:',
                hintStyle: TextStyle(fontSize: 16)),
            child: Text(
              _selectedCoursesKnown.isNotEmpty
                  ? _selectedCoursesKnown.join(', ')
                  : 'Select Courses',
            ),
          ),
        ),
        // Display selected courses
        if (_selectedCoursesKnown.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected Courses Known: ${_selectedCoursesKnown.join(', ')}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  void _showCoursesKnownDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Courses You Know'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: courseOptions.map((course) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: Text(course),
                      value: _selectedCoursesKnown.contains(course),
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (!_selectedCoursesKnown.contains(course)) {
                              _selectedCoursesKnown.add(course);
                            }
                          } else {
                            _selectedCoursesKnown.remove(course);
                          }
                        });
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {}); // Refresh parent widget
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Select'),
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
        title: const Text('Profile Form'),
      ),
      body: Center(
        child: Container(
          width: 400, // Set a specific width for the form
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
                offset: Offset(0, 5), // Shadow position
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _photoUpload(),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name*'),
                    validator: _validateName,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Phone Number (optional)'),
                    validator: _validatePhone,
                  ),
                  _genderSelection(),
                  _educationDropdown(),
                  _dateOfBirthPicker(),
                  _coursesToLearnDropdown(),
                  _coursesKnownDropdown(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Gather the data to send
                        final data = {
                          'username': widget.username,
                          'full_name': _nameController.text,
                          'phone_number': _phoneController.text,
                          'gender': _selectedGender,
                          'education': _selectedEducation ?? _manualEducation,
                          'dob': _selectedDateOfBirth != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(_selectedDateOfBirth!)
                              : null,
                          'courses_to_learn': _selectedCoursesToLearn,
                          'courses_known': _selectedCoursesKnown,
                        };

                        // Send the data to the backend
                        try {
                          final response = await http.post(
                            Uri.parse(
                                'http://192.168.56.1:3000/api/profile'), // Replace with your actual backend URL
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: json.encode(data),
                          );

                          // Check the response status
                          if (response.statusCode == 200) {
                            // Navigate to the home page or show a success message
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HhomePage(username: widget.username),
                              ),
                            );
                            // Adjust the route to your home page
                          } else {
                            // Handle error response
                            final errorResponse = json.decode(response.body);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(errorResponse['message'] ??
                                      'An error occurred')),
                            );
                          }
                        } catch (e) {
                          // Handle exceptions
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to send data: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Submit'),
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
