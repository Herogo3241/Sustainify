import 'package:flutter/material.dart';
import 'package:social_code/Pages/CommunityPage.dart';
import 'package:social_code/Pages/Profile.dart';
import 'package:social_code/Pages/TrackerPage.dart';
import 'package:social_code/Utils/AddPostPage.dart';
import 'package:social_code/main.dart';
import '../Pages/EventPage.dart';
import '../Pages/HomePage.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(title: 'Sustainify',),
    TrackerPage(),
    EventPage(),
    CommunityPage(onPostAdded: (CommunityPost ) {  },),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, -3), // changes position of shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.donut_large_outlined,
              ),
              label: 'Tracker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.festival),
              label: 'Events',
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.forum,
                ),
                label: 'Community'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.lightGreen,
          unselectedItemColor: MAINCOLOR,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
