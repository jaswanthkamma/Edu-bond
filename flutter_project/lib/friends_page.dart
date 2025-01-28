import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'friendBond_page.dart';
import 'dart:async';

class FriendsPage extends StatefulWidget {
  final String username;

  const FriendsPage({Key? key, required this.username}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  bool _showFriends = true;
  Timer? _timer;

  void startFetchingRequests() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_showFriends) {
        fetchRequests();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFriends();
    startFetchingRequests();
  }

  Future<void> fetchFriends() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.56.1:3000/api/friends?username=${widget.username}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _friends = data.map((item) {
            return {
              "username": item['username'] ?? 'Unknown',
              "course": item['course'] ?? 'No Course',
            };
          }).toList();
        });
      } else {
        print('Failed to load friends: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  Future<void> fetchRequests() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.56.1:3000/api/requests?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _requests = data.map((item) {
          return {
            "request_from": item['request_from'] ?? 'Unknown',
            "request_to": item['request_to'] ?? 'Unknown',
            "course": item['course'] ?? 'No Course',
            "status": item['status'] ?? 'pending',
            "text": item['text'] ?? 'nothing to display',
          };
        }).toList();
      });
    } else {
      print('Failed to load requests');
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  void _request(
      String fromUsername, String toUsername, String course, String status) {
    http.post(
      Uri.parse('http://192.168.56.1:3000/api/request'),
      body: json.encode({
        'from': fromUsername,
        'to': toUsername,
        'course': course,
        'status': status,
      }),
      headers: {'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        print('Request accepted');
      } else {
        print('Failed to accept request');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 100,
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
                          hintText: 'Search friends',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        textAlign: TextAlign.left,
                        onSubmitted: (value) {
                          // Implement search logic or navigation if needed
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
                      color: const Color.fromARGB(255, 53, 53, 53),
                    ),
                  ),
                ],
              ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 50, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            color: const Color.fromARGB(
                255, 249, 249, 249), // Background color for the heading section
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      // Change color on hover
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      // Reset color on exit
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFriends = true;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'Friends',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 38, // Increased font size
                            fontWeight: _showFriends
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _showFriends
                                ? const Color.fromARGB(255, 48, 121, 248)
                                : Colors.black,
                          ),
                        ),
                        if (_showFriends)
                          Container(
                            height: 4,
                            width: 50,
                            color: const Color.fromARGB(255, 60, 122, 228),
                          ),
                      ],
                    ),
                  ),
                ),
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      // Change color on hover
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      // Reset color on exit
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFriends = false;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'Requests',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 38, // Increased font size
                            fontWeight: !_showFriends
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: !_showFriends
                                ? const Color.fromARGB(255, 48, 121, 248)
                                : Colors.black,
                          ),
                        ),
                        if (!_showFriends)
                          Container(
                            height: 4,
                            width: 50,
                            color: const Color.fromARGB(255, 60, 122, 228),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 180), // Increased padding
              child: _showFriends
                  ? _friends.isEmpty
                      ? Center(child: Text('You have no friends'))
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10),
                          itemCount: _friends.length,
                          itemBuilder: (context, index) {
                            final friend = _friends[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.blue[50],
                              child: ListTile(
                                title: Text(friend['username'] ?? 'Unknown',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                  friend['course'] ?? 'No Course',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: const Color.fromARGB(
                                          255, 94, 94, 94)),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FriendBond(
                                        friendUsername:
                                            friend['username'] ?? 'Unknown',
                                        course: friend['course'] ?? 'No Course',
                                        username: widget.username,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                  : _requests.isEmpty
                      ? Center(child: Text('You have no requests'))
                      : ListView.builder(
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final request = _requests[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.blue[50],
                              child: ListTile(
                                title: Text(
                                  widget.username == request['request_to']
                                      ? request['request_from'] ?? 'Unknown'
                                      : request['request_to'],
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  'Course: ${request['course'] ?? 'No Course'}\n'
                                  '${request['text']}',
                                  //'Status: ${request['status'] ?? 'Unknown'}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (request['status'] == 'pending' &&
                                        request['request_to'] ==
                                            widget.username) ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          _request(
                                              request['request_from'],
                                              request['request_to'],
                                              request['course'],
                                              'approved');
                                          fetchRequests(); // Refresh requests after accepting
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: Text('Accept'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _request(
                                              request['request_from'],
                                              request['request_to'],
                                              request['course'],
                                              'rejected');
                                          fetchRequests(); // Refresh requests after rejecting
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text('Reject'),
                                      ),
                                    ] else ...[
                                      Text('${request['status']}'),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}
