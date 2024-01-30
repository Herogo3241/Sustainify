import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_code/Pages/CommunityPage.dart';
import 'package:social_code/Pages/TrackerPage.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('lib/Assets/World.png'),
          onPressed: () {},
        ),
        title: Text(
          'Sustainify',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            FutureBuilder<String>(
              future: _getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      'Welcome, ${snapshot.data}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  } else {
                    return Text(
                      'Welcome, User!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Discover ways to live sustainably!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _showRecycleDialog(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              icon: Icon(
                Icons.recycling_outlined,
                color: Colors.white,
              ),
              label: Text(
                'Recycle Items',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrackerPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              icon: Icon(
                Icons.track_changes,
                color: Colors.white,
              ),
              label: Text(
                'Track Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityPage(
                      onPostAdded: (CommunityPost) {},
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              icon: Icon(
                Icons.group_outlined,
                color: Colors.white,
              ),
              label: Text(
                'Join the Community',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40),
            // Additional content section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help make a difference!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your actions matter. Join us in creating a sustainable future for all.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    String username = 'User';

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        username = snapshot.data()?['username'] ?? 'User';
      }
    }

    return username;
  }

  void _showRecycleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecycleDialog();
      },
    );
  }
}

class RecycleDialog extends StatefulWidget {
  @override
  _RecycleDialogState createState() => _RecycleDialogState();
}

class _RecycleDialogState extends State<RecycleDialog> {
  double recycleAmount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Recycle Amount'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select the amount of items to recycle (in kgs):'),
          SizedBox(height: 20),
          Slider(
            value: recycleAmount,
            min: 0,
            max: 20,
            onChanged: (newValue) {
              setState(() {
                recycleAmount = newValue;
              });
            },
          ),
          SizedBox(height: 10),
          Text('Current Value: ${recycleAmount.toStringAsFixed(1)} kgs'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Store recycleAmount in Firestore
              _storeRecycleAmount(recycleAmount);
              Navigator.of(context).pop();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _storeRecycleAmount(double newAmount) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      // Retrieve current recycle amount from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('recycle_tracker')
          .doc(userId)
          .get();

      double currentAmount = 0;

      if (snapshot.exists) {
        currentAmount = (snapshot.data() ?? {})['recycleAmount'] ?? 0;
      }

      double totalAmount = currentAmount + newAmount;

      // Update document in Firestore with the new total amount
      await FirebaseFirestore.instance
          .collection('recycle_tracker')
          .doc(userId)
          .set({'recycleAmount': totalAmount, 'userId': userId});
    }
  }
}
