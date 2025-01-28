import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/edubondImage.jpg',
                height: 50,
              ),
            ),
            const Text(
              'EduBond',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cursive',
                color: Color.fromARGB(255, 41, 40, 40),
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.blueAccent,
        actions: [
          _buildHeaderButton(context, 'Courses', Icons.menu_book, () {
            print('Courses Page');
          }),
          _buildHeaderButton(context, 'About', Icons.info_outline, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            );
          }),
          _buildSearchBar(),
          _buildHeaderButton(context, 'Profile', Icons.person, () {
            print('Profile Page');
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // About EduBond Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'About EduBond',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  Text(
                    'EduBond connects learners with study companions, fostering collaboration and enhancing the e-\n'
                    'learning experience. Join us to find your perfect study partner and achieve your educational goals\n'
                    'together.',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 90),
              // Our Team Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Our Team',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Meet the dedicated individuals behind EduBond, committed to enhancing your learning experience.',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 40),
                ],
              ),
              const SizedBox(height: 20),
              // Team members section
              GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTeamMember('assets/images/druva.jpg', 'Druva Kumar'),
                  _buildTeamMember('assets/images/naresh.jpg', 'Naresh'),
                  _buildTeamMember(
                      'assets/images/manohar.jpg', 'Manohar Reddy'),
                  _buildTeamMember('assets/images/jaswanth.jpg', 'Jaswanth'),
                  _buildTeamMember('assets/images/rajesh.jpg', 'Rajesh'),
                  _buildTeamMember('assets/images/sai.jpg', 'Sai Krishna'),
                ],
              ),
              // Footer Section
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
                      '© 2024 EduBond. All rights reserved. Empowering learners to connect and grow together.',
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
                          icon: Icon(Icons.linked_camera, color: Colors.white),
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
        ),
      ),
    );
  }

  Widget _buildHeaderButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: 200,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white24,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(String imagePath, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }
}
