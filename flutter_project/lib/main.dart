import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'mail_otp.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'friends_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduBond',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoginHovered = false;
  bool isSignupHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to pure white
      body: Stack(
        children: [
          Row(
            children: [
              // Right side image
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(
                        right: 100), // Keep the image margin
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/mainImage.jpg'),
                        fit: BoxFit.cover, // Fills the container
                      ),
                    ),
                    width: 500, // Keep the image width
                    height: 500, // Keep the image height
                  ),
                ),
              ),

              // Left side with Project Name and Tagline
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left:
                            150), // Adjust left padding to move text further right
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title "EduBond"
                        const Text(
                          'EduBond',
                          style: TextStyle(
                            fontSize: 70, // Font size for the title
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(
                            height: 3), // Space between title and tagline

                        // Center-align tagline below title
                        Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  20), // Adjust padding as needed for alignment
                          child: const Text(
                            'Find your way to learn',
                            style: TextStyle(
                              fontSize: 25, // Font size for the tagline
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center, // Center-align text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Logo in the top left corner
          Positioned(
            top: 20,
            left: 20,
            child: Image.asset(
              'assets/images/edubondImage.jpg',
              width: 80, // Set the width for the logo
              height: 80, // Set the height for the logo
            ),
          ),

          // Login and Signup buttons at the top right corner
          Positioned(
            top: 40,
            right: 40,
            child: Row(
              children: [
                // Login Button with hover effect
                MouseRegion(
                  onEnter: (_) => setState(() => isLoginHovered = true),
                  onExit: (_) => setState(() => isLoginHovered = false),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isLoginHovered ? Colors.black : Colors.white,
                      foregroundColor:
                          isLoginHovered ? Colors.white : Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15), // Adjusted padding
                      textStyle: const TextStyle(
                          fontSize: 20), // Increased button text size
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(width: 20),

                // Signup Button with hover effect
                MouseRegion(
                  onEnter: (_) => setState(() => isSignupHovered = true),
                  onExit: (_) => setState(() => isSignupHovered = false),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MailOtpPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSignupHovered ? Colors.black : Colors.white,
                      foregroundColor:
                          isSignupHovered ? Colors.white : Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15), // Adjusted padding
                      textStyle: const TextStyle(
                          fontSize: 20), // Increased button text size
                    ),
                    child: const Text('Signup'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
