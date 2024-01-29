import 'package:flutter/material.dart';
import 'package:social_code/Utils/CommunityPostWidget.dart';
import '../Utils/AddPostPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPage extends StatefulWidget {
  final Function(CommunityPost) onPostAdded;
  CommunityPage({Key? key, required this.onPostAdded}) : super(key: key);
  
  get title => null;
  
  get content => null;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<CommunityPost>> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = _firestore
        .collection('posts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityPost(
                  title: doc['title'],
                  content: doc['content'],
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: StreamBuilder<List<CommunityPost>>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No posts available'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return CommunityPostWidget(post: snapshot.data![index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostPage(
                onPostAdded: (post) {
                  addPostToFirestore(post);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.create_rounded),
      ),
    );
  }

  void addPostToFirestore(CommunityPost post) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('posts').add({
          'userId': user.uid,
          'title': post.title,
          'content': post.content,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error adding post to Firestore: $e');
    }
  }

  AppBar appBar() {
    return AppBar(
      title: Text('Community'),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Add your notification logic here
          },
        ),
      ],
    );
  }
}
  




class CommunityPost {
  final String title;
  final String content;

  CommunityPost({required this.title, required this.content});
}


