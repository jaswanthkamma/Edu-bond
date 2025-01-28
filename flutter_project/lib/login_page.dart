import 'package:flutter/material.dart';
import 'home_page.dart';
import 'mail_otp.dart';
import 'profile_page.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // Import the HTTP package

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoginHovered = false;
  bool isSignUpHovered = false;
  bool _isPasswordVisible =
      false; // Add a variable to toggle password visibility

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the data to be sent to the backend
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      // Send the data to the backend for validation
      final response = await http.post(
        Uri.parse(
            'http://192.168.56.1:3000/login'), // Change to your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      // Check the response from the backend
      if (response.statusCode == 200) {
        // If the server returns an OK response, navigate to HomePage
        final respons = await http.post(
          Uri.parse(
              'http://192.168.56.1:3000/check_profile'), // Change to your backend URL
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': username,
            'password': password,
          }),
        );
        if (respons.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(username: username)),
          );
        } else if (respons.statusCode == 201) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HhomePage(username: username)),
          );
        } else {
          // If the server returns an error, show an error message
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'An error occurred';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        // If the server returns an error, show an error message
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'An error occurred';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  // Function to navigate to Sign-Up page
  void _goToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MailOtpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            // Left side with login form
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      width: 450, // Wider container for the login form
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 10),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 40, // Increased font size
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12), // Adjusted spacing
                            Row(
                              children: [
                                const Text("Don't have an account yet?",
                                    style: TextStyle(
                                        fontSize: 18)), // Increased font size
                                const SizedBox(width: 5),
                                MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => isSignUpHovered = true),
                                  onExit: (_) =>
                                      setState(() => isSignUpHovered = false),
                                  child: GestureDetector(
                                    onTap: _goToSignUpPage,
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // Increased font size
                                        decoration: isSignUpHovered
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Username Field
                            const Text(
                              'Username',
                              style: TextStyle(
                                  fontSize: 20), // Increased font size
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your username',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password Field with Eye Icon
                            const Text(
                              'Password',
                              style: TextStyle(
                                  fontSize: 20), // Increased font size
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText:
                                    !_isPasswordVisible, // Toggle visibility
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible; // Toggle password visibility
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) =>
                                    _submitForm(), // Submit on Enter
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Login Button with hover effect
                            Center(
                              child: MouseRegion(
                                onEnter: (_) =>
                                    setState(() => isLoginHovered = true),
                                onExit: (_) =>
                                    setState(() => isLoginHovered = false),
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isLoginHovered
                                        ? Colors.black
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 80,
                                      vertical: 16,
                                    ),
                                    side: BorderSide(
                                      color: Colors.black,
                                    ),
                                    foregroundColor: isLoginHovered
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        fontSize: 20), // Increased font size
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right side image
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/loginImage.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Top left corner 'AppBar' with curved edges
    );
  }
}
