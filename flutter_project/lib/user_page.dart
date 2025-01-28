import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserPage extends StatefulWidget {
  final String username;
  final String fromUsername; // Add this parameter for from username

  UserPage({required this.username, required this.fromUsername});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List learningUsers = [];
  List learntUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Function to fetch users who are learning and learnt
  Future<void> fetchUsers() async {
    try {
      final username = widget.username;
      final learningResponse = await http.get(Uri.parse(
          'http://192.168.56.1:3000/users/learningCourses?username=$username'));
      final learntResponse = await http.get(Uri.parse(
          'http://192.168.56.1:3000/users/learntCourses?username=$username'));

      if (learningResponse.statusCode == 200 &&
          learntResponse.statusCode == 200) {
        setState(() {
          learningUsers = json.decode(learningResponse.body);
          learntUsers = json.decode(learntResponse.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blueAccent,
        title: _isSearching
            ? Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by username',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        textAlign: TextAlign.left,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPage(
                                  username: widget.username,
                                  fromUsername: widget.fromUsername,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/images/edubondImage.jpg',
                      height: 50,
                    ),
                  ),
                  Text(
                    'EduBond',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Roboto',
                      color: const Color.fromARGB(255, 53, 53, 53),
                    ),
                  ),
                ],
              ),
        toolbarHeight: 110,
        actions: _isSearching
            ? null // Hide the search button when in search mode
            : [
                IconButton(
                  icon: Icon(Icons.search, size: 30, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = true; // Enter search mode
                    });
                  },
                ),
              ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 20), // Add some padding at the top
                Expanded(
                  child: Row(
                    children: [
                      // Learning users list
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UserLearning Courses:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: learningUsers.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No users are currently learning this course.',
                                        style: TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: learningUsers.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(), // Separator between rows
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                learningUsers[index]
                                                        ['username'] ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showBondDialog(
                                                      learningUsers[index]
                                                          ['course'],
                                                      widget.username);
                                                },
                                                child: Text('Bond'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10), // Add some space between the columns

                      // Learnt users list
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Users Learnt Courses:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: learntUsers.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'The users have not completed learning any course.',
                                        style: TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: learntUsers.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(), // Separator between rows
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                learntUsers[index]['course'] ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showBondDialog(
                                                      learntUsers[index]
                                                          ['course'],
                                                      widget.username);
                                                },
                                                child: Text('Bond'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Show the bond dialog
  void _showBondDialog(String toUsername, String courseFromPreviousPage) {
    TextEditingController _optionalCourseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Bond'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _optionalCourseController,
                decoration: InputDecoration(
                  labelText: 'Optional Course (if any)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _requestBond(toUsername, courseFromPreviousPage,
                    _optionalCourseController.text);
                Navigator.of(context).pop();
              },
              child: Text('Request Bond'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to request bond
  Future<void> _requestBond(String toUsername, String courseFromPreviousPage,
      String optionalText, String course) async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1:3000/request-bond'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'from':
            widget.fromUsername, // Get from username from the passed parameter
        'to': toUsername, // Get to username from the button clicked
        'course': course, // Course from the previous page
        'additional_info':
            optionalText.isNotEmpty ? optionalText : null, // Optional course
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bond request sent successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send bond request.')),
      );
    }
  }
}
