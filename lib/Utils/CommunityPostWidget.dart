import 'package:flutter/material.dart';
import 'package:social_code/Pages/CommunityPage.dart';
import 'package:social_code/Utils/CommunityPostDetailPage.dart';

class CommunityPostWidget extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityPostDetailPage(post: post),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  post.content.length < 100
                      ? post.content
                      : '${post.content.substring(0, 100)}...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
