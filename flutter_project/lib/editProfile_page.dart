import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final String username;

  // Correctly define message as a named parameter
  const EditProfilePage({Key? key, required this.username}) : super(key: key);
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  DateTime _selectedDateOfBirth = DateTime.now();
  List<String> learningCourses = ["Flutter", "Python"];
  List<String> learntCourses = ["HTML", "CSS", "JavaScript"];
  bool hasProfileImage = true;
  bool isModified = false;
  DateTime currentDate = DateTime.now();
  File? _selectedImage;

  String username = "";
  String fullName = "John Doe";
  String dob = "01/01/1990";
  String email = "johndoe@example.com";
  String education = "undergraduate";
  String phoneNumber = '555930082';

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.username); // Fetch user profile on page load
  }

// Assuming you need to send a username to fetch the user profile.
  Future<void> fetchUserProfile(String username) async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1:3000/user-profile'),
      headers: {
        'Content-Type': 'application/json', // Set content type for JSON
      },
      body: json.encode({
        // Include any required body data here, if necessary
        'username': username, // Example data, can be adjusted based on your API
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Assign values to the variables
      this.username = data['username'];
      //print(username);
      fullName = data['full_name'] ?? 'none';
      currentDate = DateTime.parse(data['dob']); // Use DateTime.parse()
      dob = DateFormat('dd-MM-yyyy').format(currentDate);
      email = data['email'] ?? 'none';
      //print(fullName);
      education = data['education'] ?? 'none';
      phoneNumber = data['phone_number'] ?? 'none';
      setState(() {}); // Refresh UI with the new data
    } else {
      throw Exception('Failed to load user profile: ${response.reasonPhrase}');
    }
  }

  Future<void> updateProfile() async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1:3000/update-profile'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'education': education,
        'phoneNumber': phoneNumber,
        'dob': DateFormat('yyyy-MM-dd').format(currentDate),
      }),
    );

    // Display Snackbar based on the response status code
    if (response.statusCode == 200) {
      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return false; // Phone number is optional
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return false;
      //return 'Please enter a valid 10-digit phone number';
    }
    return true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<DateTime?> dateOfBirthPicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    return picked;
  }

  Widget dateOfBirthWidget() {
    return InkWell(
      onTap: () async {
        final date = await dateOfBirthPicker();
        if (date != null) {
          setState(() {
            _selectedDateOfBirth = date;
            isModified = true;
          });
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

  // Function to display the education dropdown and return selected education
  Future<String?> educationDropdown(
      BuildContext context, String? initialEducation) async {
    String? selectedEducation;

    // List of education options
    final List<String> educationOptions = [
      'High School',
      'Undergraduate',
      'Postgraduate',
      'Other'
    ];

    // Show dialog for selecting education
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Education'),
          content: SingleChildScrollView(
            child: ListBody(
              children: educationOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedEducation,
                  onChanged: (value) {
                    selectedEducation = value;
                    Navigator.of(context).pop(value); // Return selected value
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(), // Close dialog
            ),
          ],
        );
      },
    );

    return result ??
        initialEducation; // Return the selected education or initial value
  }

// Widget to display and select the education type
  Widget educationDropdownWidget({
    required BuildContext context,
    required String? selectedEducation,
    required ValueChanged<String?> onEducationSelected,
  }) {
    return InkWell(
      onTap: () async {
        final education = await educationDropdown(context, selectedEducation);
        if (education != null) {
          onEducationSelected(education);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Education Type*'),
        child: Text(
          selectedEducation ?? 'Select Education',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

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

  Future<String?> editField(String title, String currentValue) async {
    TextEditingController fieldController =
        TextEditingController(text: currentValue);
    String? result;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: fieldController,
          decoration: InputDecoration(hintText: "Enter $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final input = fieldController.text; // Get the input value
              if (_validatePhone(input)) {
                result = input; // Assign valid input to result
                Navigator.pop(context); // Close the dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Please enter a valid 10-digit phone number.'),
                  ),
                );
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );

    return result; // Return the result after the dialog closes
  }

  void editCourses(List<String> courses, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: SingleChildScrollView(
          child: Column(
            children: courseOptions.map((course) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return CheckboxListTile(
                    title: Text(course),
                    value: courses.contains(course),
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          courses.add(course);
                        } else {
                          courses.remove(course);
                        }
                      });
                      isModified = true;
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // Update the UI to reflect changes
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: hasProfileImage
                        ? AssetImage('assets/images/${widget.username}.jpg')
                        : null,
                    child:
                        !hasProfileImage ? Icon(Icons.person, size: 60) : null,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      //_pickImage();
                      setState(() {
                        hasProfileImage = false;
                        isModified = true;
                      });
                    },
                    child: Text("Remove Photo"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage();
                      // Implement change photo functionality
                    },
                    child: Text("Change Photo"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ProfileField(
                label: "Username",
                value: username,
                editable: false,
              ),
              ProfileField(
                label: "Full Name",
                value: fullName,
                editable: false,
              ),
              ProfileField(
                label: "Education",
                value: education,
                editable: true,
                onEdit: () async {
                  final edu = await educationDropdown(context, education);
                  print(edu);
                  if (edu != null) {
                    setState(() {
                      education = edu;
                      isModified = true;
                    });
                  }
                },
              ),
              ProfileField(
                label: "Phone Number",
                value: phoneNumber,
                editable: true,
                onEdit: () async {
                  final newValue = await editField("Phone Number", phoneNumber);

                  // If the new value is valid, update the phone number
                  if (newValue != null) {
                    setState(() {
                      phoneNumber =
                          newValue; // Update the phone number only if valid
                      isModified = true;
                    });
                  }
                },
              ),
              ProfileField(
                label: "Date of Birth",
                value: dob,
                editable: true,
                onEdit: () async {
                  final date = await dateOfBirthPicker();
                  print(date);
                  if (date != null) {
                    currentDate = date;
                  }
                  if (date != null) {
                    setState(() {
                      _selectedDateOfBirth = date;
                      dob = DateFormat('dd-MM-yyyy').format(date);
                      isModified = true;
                    });
                  }
                },
              ),
              ProfileField(
                label: "Email",
                value: email,
                editable: true,
                onEdit: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Change Email'),
                        content: MailOtpDialog(
                          onEmailChanged: (newEmail) {
                            setState(() {
                              email = newEmail;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Mail updated successfully')),
                              );
                            });
                          },
                          username: widget.username,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 24),
              SectionWithEditButton(
                title: "Learning Courses",
                items: learningCourses,
                onEdit: () => editCourses(learningCourses, "Learning Courses"),
              ),
              SizedBox(height: 24),
              SectionWithEditButton(
                title: "Learnt Courses",
                items: learntCourses,
                onEdit: () => editCourses(learntCourses, "Learnt Courses"),
              ),
              SizedBox(height: 24),
              if (isModified)
                ElevatedButton(
                  onPressed: () {
                    updateProfile();
                    setState(() {
                      isModified = false;
                    });
                    // Implement save changes functionality
                  },
                  child: Text("Save Changes"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool editable;
  final VoidCallback? onEdit;

  ProfileField(
      {required this.label,
      required this.value,
      this.editable = false,
      this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(value),
              if (editable)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionWithEditButton extends StatelessWidget {
  final String title;
  final List<String> items;
  final VoidCallback onEdit;

  SectionWithEditButton(
      {required this.title, required this.items, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
        ...items.map((item) => ListTile(title: Text(item))).toList(),
      ],
    );
  }
}

class MailOtpDialog extends StatefulWidget {
  final Function(String) onEmailChanged;
  final String username;

  const MailOtpDialog(
      {Key? key, required this.onEmailChanged, required this.username})
      : super(key: key);

  @override
  _MailOtpDialogState createState() => _MailOtpDialogState();
}

class _MailOtpDialogState extends State<MailOtpDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mailOtpController = TextEditingController();
  bool _isMailOtpFieldVisible = false;
  bool _isMailOtpSent = false;
  int _mailOtpCountdown = 60;
  Timer? _timer;

  Future<void> _sendMailOtp() async {
    final email = _emailController.text;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:3000/send-otp'), // Your backend URL
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isMailOtpFieldVisible = true;
          _isMailOtpSent = true;
          _mailOtpCountdown = 60; // Reset countdown
        });
        _startMailOtpCountdown();
      } else {
        print('Failed to send OTP: ${response.body}');
      }
    } catch (error) {
      print('Error sending OTP: $error');
    }
  }

  void _startMailOtpCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mailOtpCountdown > 0) {
        setState(() {
          _mailOtpCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isMailOtpSent = false; // Allow resending of OTP
          _mailOtpCountdown = 60; // Reset countdown
        });
      }
    });
  }

  Future<void> _verifyMailOtp() async {
    final enteredOtp = _mailOtpController.text;
    final email = _emailController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.56.1:3000/verify-mailotp'), // Your backend URL
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
            {'email': email, 'otp': enteredOtp, 'username': widget.username}),
      );

      if (response.statusCode == 200) {
        widget.onEmailChanged(email); // Pass the new email back
        Navigator.of(context).pop(); // Close the dialog
      } else if (response.statusCode == 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cannot update email: Email already exists'),
          ),
        );
        // Optionally close the dialog if needed
        Navigator.of(context).pop(); // Close the dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } catch (error) {
      print('Error verifying OTP: $error');
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _emailController.dispose();
    _mailOtpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Enter new email'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isMailOtpSent ? null : _sendMailOtp,
          child: const Text('Send OTP'),
        ),
        const SizedBox(height: 10),
        if (_isMailOtpFieldVisible) ...[
          TextField(
            controller: _mailOtpController,
            decoration: const InputDecoration(labelText: 'Enter OTP'),
          ),
          const SizedBox(height: 10),
          if (_mailOtpCountdown > 0)
            Text('OTP is valid for $_mailOtpCountdown seconds',
                style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: (_mailOtpCountdown > 0) ? _verifyMailOtp : null,
            child: const Text('Verify OTP'),
          ),
        ],
      ],
    );
  }
}

Widget educationDropdown({
  required String? selectedEducation,
  required void Function(String) onEducationChanged,
}) {
  final List<String> educationOptions = [
    'High School',
    'Undergraduate',
    'Postgraduate',
    'Other'
  ];
  String? manualEducation;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Education Type'),
            value: selectedEducation,
            items: educationOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  if (value != 'Other') {
                    manualEducation = null; // Reset manual input if not "Other"
                    onEducationChanged(value);
                  }
                  setState(
                      () => manualEducation = value == 'Other' ? '' : null);
                }
              });
            },
            validator: (value) =>
                value == null ? 'Please select an education type' : null,
          ),
          // Manual education input appears if "Other" is selected
          if (selectedEducation == 'Other') ...[
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Specify Education'),
              onChanged: (value) {
                setState(() {
                  manualEducation = value;
                  onEducationChanged(value); // Send the manual input value back
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Please specify your education'
                  : null,
            ),
          ],
        ],
      );
    },
  );
}
