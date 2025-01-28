import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'profile_page.dart';

class SignupPage extends StatefulWidget {
  final String email;

  const SignupPage({Key? key, required this.email}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;
  Icon _passwordStrengthIcon = const Icon(Icons.info_outline);

  bool isSignupHovered = false;
  bool _isPasswordVisible = false; // To toggle password visibility
  bool _isConfirmPasswordVisible =
      false; // To toggle confirm password visibility

  Future<bool> _checkUsernameExists(String username, String password) async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.56.1:3000/check-username'), // Update with your backend URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'email': widget.email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'];
    } else {
      throw Exception('Failed to check username');
    }
  }

  bool _isPasswordValid(String password) {
    final RegExp lowerCase = RegExp(r'[a-z]');
    final RegExp upperCase = RegExp(r'[A-Z]');
    final RegExp digit = RegExp(r'\d');
    final RegExp specialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    return lowerCase.hasMatch(password) &&
        upperCase.hasMatch(password) &&
        digit.hasMatch(password) &&
        specialCharacter.hasMatch(password);
  }

  void _getPasswordStrength(String password) {
    if (password.length < 4) {
      _passwordStrength = 'Weak password';
      _passwordStrengthColor = Colors.red;
      _passwordStrengthIcon = Icon(Icons.close, color: Colors.redAccent);
    } else if (_isPasswordValid(password)) {
      if (password.length >= 8) {
        _passwordStrength = 'Strong password';
        _passwordStrengthColor = Colors.green;
        _passwordStrengthIcon =
            Icon(Icons.check_circle, color: Colors.greenAccent);
      } else {
        _passwordStrength = 'Medium password';
        _passwordStrengthColor = Colors.orange;
        _passwordStrengthIcon =
            Icon(Icons.remove_circle, color: Colors.orangeAccent);
      }
    } else {
      _passwordStrength = 'Weak password';
      _passwordStrengthColor = Colors.red;
      _passwordStrengthIcon = Icon(Icons.close, color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Setting entire page background to white
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/signupImage.jpg'), // Update with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(5, 10),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter a strong password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          suffixText: _passwordStrength,
                          suffixStyle: TextStyle(
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        onChanged: (password) {
                          setState(() {
                            _getPasswordStrength(password);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                      ),
                      const SizedBox(height: 20),
                      MouseRegion(
                        onEnter: (_) => setState(() => isSignupHovered = true),
                        onExit: (_) => setState(() => isSignupHovered = false),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSignupHovered ? Colors.black : Colors.white,
                            foregroundColor:
                                isSignupHovered ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.black),
                            elevation: 5,
                          ),
                          onPressed: () async {
                            bool usernameExists = await _checkUsernameExists(
                                _usernameController.text,
                                _passwordController.text);

                            if (usernameExists) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content:
                                        const Text('Username already exists!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content:
                                        const Text('Passwords do not match!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (_isPasswordValid(
                                _passwordController.text)) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                      username: _usernameController.text),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: const Text(
                                        'Password does not meet the criteria!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: const Text('Signup',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0, top: 30.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Image.asset(
                'assets/images/edubondImage.jpg', // Path to the logo
                width: 70,
                height: 70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
