import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String Title;

  const HomePage({super.key, required this.Title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.scale(
          scale: 1.2,
          child: IconButton(
            icon: Image.asset('lib/Assets/World.png'),
            onPressed: () {},
          ),
        ),
        title: Text('Sustainify'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Updated here
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Welcome, User!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Gamifying Sustainability!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add navigation to the specific route
              },
              child: Text('Explore More'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add navigation to another route
              },
              child: Text('Get Involved'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add navigation to another route
              },
              child: Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }
}
