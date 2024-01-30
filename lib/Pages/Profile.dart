import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_code/Pages/SignUp.dart';
import 'package:social_code/Utils/Navbar.dart';

class Profile extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late User _user;
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
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

  Future<void> _uploadImage() async {
    try {
      final String fileName = 'profile_pics/${_user.uid}.jpg';
      final Reference reference = _storage.ref().child(fileName);
      await reference.putFile(_imageFile);
      final String downloadURL = await reference.getDownloadURL();

      // Save downloadURL to user's profile or wherever you store user data

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: const NetworkImage(
                          'URL_TO_DEFAULT_IMAGE'),
                  backgroundColor: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<String>(
                future: _getUsername(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      'Name: ${snapshot.data}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return Text(
                      'user: N/A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                }
                },
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${_user.email}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Profile Picture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
