import 'package:flutter/material.dart';
import 'package:social_code/Pages/CommunityPage.dart';
import 'package:social_code/Utils/CommunityPostDetailPage.dart';

class CommunityPostWidget extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0 , left: 16 , right: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey, // Define the color of your border
              width: 1.0, // Define the width of your border
            ),
          ),
        ),
        child: ListTile(
          title: Text(post.title),
          subtitle: Text(
            post.content.length < 100 ? post.content : '${post.content.substring(0, 100)}...', // Display initial preview of content
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityPostDetailPage(post: post),
              ),
            );
          },
        ),
      ),
    );
  }
}
