import 'package:flutter/material.dart';
import 'user_list.dart';
import 'friends_page.dart';
import 'main.dart';
import 'editProfile_page.dart';
import 'about_page.dart';

class HhomePage extends StatefulWidget {
  final String username;

  const HhomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HhomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90), // Set your desired height
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 74, 176, 26),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30), // Adjust radius as needed
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 90,
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
                              hintText: 'Search courses',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            textAlign: TextAlign.left,
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserListPage(
                                      searchValue: value,
                                      fromUsername: widget.username,
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
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                          color: const Color.fromARGB(255, 53, 53, 53),
                        ),
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                icon: Icon(Icons.search,
                    size: 35, color: const Color.fromARGB(255, 8, 8, 8)),
                onPressed: () {
                  setState(() {
                    _isSearching = true; // Enter search mode
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.group,
                    size: 35, color: const Color.fromARGB(255, 8, 8, 8)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FriendsPage(username: widget.username),
                    ),
                  );
                  print('Friends Page');
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 35, color: const Color.fromARGB(255, 8, 8, 8)),
                onSelected: (value) {
                  if (value == 'Courses') {
                    print('Courses Page');
                  } else if (value == 'About') {
                    print('About Us Page');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutPage(),
                      ),
                    );
                  } else if (value == 'Profile') {
                    print('Profile Page');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          username: widget.username,
                        ),
                      ),
                    );
                  } else if (value == 'logout') {
                    print('logging out');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'Courses',
                      child: Text('Courses'),
                    ),
                    PopupMenuItem<String>(
                      value: 'About',
                      child: Text('About'),
                    ),
                    PopupMenuItem<String>(
                      value: 'Profile',
                      child: Text('Profile'),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('logout'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/backgroundImage.jpg',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Connect with Learning Companions',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '...Discover courses and find study partners...',
                        style: TextStyle(
                          fontSize: 23,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(32),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'How It Works',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildHowItWorksStep(
                            icon: Icons.search,
                            title: 'Search Courses',
                            description:
                                'Browse through our extensive list of courses...',
                          ),
                          _buildHowItWorksStep(
                            icon: Icons.group,
                            title: 'Find Study Partners',
                            description: 'View profiles of other learners...',
                          ),
                          _buildHowItWorksStep(
                            icon: Icons.chat,
                            title: 'Connect & Learn',
                            description:
                                'Chat, exchange files, and hold video conferences...',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'EduBond',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('About',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 20),
                          TextButton(
                            onPressed: () {},
                            child: Text('Courses',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 20),
                          TextButton(
                            onPressed: () {},
                            child: Text('Resources',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '© 2024 EduBond. All rights reserved.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.facebook, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Icon(icon, size: 40, color: const Color.fromARGB(255, 8, 8, 8)),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          width: 200,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HhomePage(username: ''),
    debugShowCheckedModeBanner: false,
  ));
}
