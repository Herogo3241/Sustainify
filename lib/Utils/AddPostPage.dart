import 'package:flutter/material.dart';
import 'package:social_code/Pages/CommunityPage.dart';

class AddPostPage extends StatefulWidget {
  final Function(CommunityPost) onPostAdded;

  const AddPostPage({Key? key, required this.onPostAdded}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a post'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Submit the post
              final String title = _titleController.text;
              final String content = _contentController.text;
              if (title.isNotEmpty && content.isNotEmpty) {
                CommunityPost newPost =
                    CommunityPost(title: title, content: content);
                widget.onPostAdded(newPost);
                Navigator.pop(context); // Navigate back to the previous page
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Title and Content are required')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 40.0),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _contentController,
                  maxLines: null, // Infinite number of lines
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(), // Add border for visual distinction
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
