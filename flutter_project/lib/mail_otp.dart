import 'package:flutter/material.dart';
import 'dart:async'; // For countdown timer
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // For jsonEncode
import 'signup_page.dart'; // Import your actual SignupPage

class MailOtpPage extends StatefulWidget {
  const MailOtpPage({super.key});

  @override
  _MailOtpPageState createState() => _MailOtpPageState();
}

class _MailOtpPageState extends State<MailOtpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mailOtpController = TextEditingController();

  bool _isMailOtpFieldVisible = false;
  bool _isMailOtpSent = false;
  int _mailOtpCountdown = 60;
  Timer? _timer;
  bool isSendOtpHovered = false;
  bool isVerifyOtpHovered = false;

  // Send OTP to the entered email via backend
  Future<void> _sendMailOtp() async {
    final email = _emailController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.56.1:3000/send-otp'), // Replace with your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isMailOtpFieldVisible = true;
          _isMailOtpSent = true;
          _mailOtpCountdown = 60; // Reset countdown to 60 seconds
        });
        _startMailOtpCountdown();
        print('OTP sent to email: $email'); // For demonstration purposes
      } else {
        print('Failed to send OTP: ${response.body}');
      }
    } catch (error) {
      print('Error sending OTP: $error');
    }
  }

  // Start the countdown timer for OTP
  void _startMailOtpCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mailOtpCountdown > 0) {
        setState(() {
          _mailOtpCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isMailOtpSent = false;
          _mailOtpCountdown = 60;
        });
      }
    });
  }

  // Verify the OTP with the backend
  Future<void> _verifyMailOtp() async {
    final enteredOtp = _mailOtpController.text;
    final email = _emailController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.56.1:3000/verify-otp'), // Replace with your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email, 'otp': enteredOtp}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP is valid!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupPage(email: email),
          ),
        );
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
    _timer?.cancel();
    _emailController.dispose();
    _mailOtpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            // Left side with email and OTP form
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(
                          40), // Adjust padding for more space
                      width: 500, // Increase the width of the container
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Email Verification',
                            style: TextStyle(
                              fontSize: 36, // Increased font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email field with "Send OTP" button
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  style: const TextStyle(
                                      fontSize: 18), // Increased text size
                                ),
                              ),
                              const SizedBox(width: 10),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => isSendOtpHovered = true),
                                onExit: (_) =>
                                    setState(() => isSendOtpHovered = false),
                                child: ElevatedButton(
                                  onPressed:
                                      _isMailOtpSent ? null : _sendMailOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSendOtpHovered
                                        ? Colors.black
                                        : Colors.white,
                                    side: const BorderSide(
                                      color: Colors.black,
                                    ),
                                    foregroundColor: isSendOtpHovered
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  child: const Text('Send OTP'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // OTP field (only visible if OTP is sent)
                          if (_isMailOtpFieldVisible) ...[
                            TextField(
                              controller: _mailOtpController,
                              decoration: const InputDecoration(
                                labelText: 'Enter OTP',
                              ),
                              style: const TextStyle(
                                  fontSize: 18), // Increased text size
                            ),
                            const SizedBox(height: 10),
                            if (_mailOtpCountdown > 0)
                              Text(
                                'OTP is valid for $_mailOtpCountdown seconds',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16), // Increased text size
                              ),
                            const SizedBox(height: 20),
                            MouseRegion(
                              onEnter: (_) =>
                                  setState(() => isVerifyOtpHovered = true),
                              onExit: (_) =>
                                  setState(() => isVerifyOtpHovered = false),
                              child: ElevatedButton(
                                onPressed: (_mailOtpCountdown > 0)
                                    ? _verifyMailOtp
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isVerifyOtpHovered
                                      ? Colors.black
                                      : Colors.white,
                                  side: const BorderSide(
                                    color: Colors.black,
                                  ),
                                  foregroundColor: isVerifyOtpHovered
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                child: const Text('Verify OTP'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right side with image
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mailImage.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Top left corner logo and project name
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0, top: 30.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Image.asset(
                'assets/images/edubondImage.jpg', // Path to the logo
                width: 70, // Logo width
                height: 70, // Logo height
              ),
              const SizedBox(width: 8), // Space between logo and title
              const Text(
                'Edubond',
                style: TextStyle(
                  fontSize: 40, // Title font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
