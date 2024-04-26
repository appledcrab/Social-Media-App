//Main homescreen that will have the feed.
// News feed from … community or following
// Infinite? Scroll of posts
// Being able to interact with posts
// Like, comment

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/services/firestore_service.dart';
import 'package:social_media_app/widgets/post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final FirestoreService _firestoreService = FirestoreService();
  AuthService _authService = AuthService();

  List<Map<String, dynamic>> _followedUserPosts = [];

  void initState() {
    super.initState();
    _loadFollowedUserPosts();
  }

  void _loadFollowedUserPosts() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user logged in');
      return;
    }

    String currentUserId = currentUser.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    try {
      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic> followList = (userSnapshot.data()
              as Map<String, dynamic>?)?['metadata']['followList'] ??
          [];

      // Now get posts from users in the followList
      if (followList.isNotEmpty) {
        QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
            .collection('test')
            .where('author_id', whereIn: followList)
            .get();

        List<Map<String, dynamic>> followedPosts = postsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {
          _followedUserPosts = followedPosts;
        });
      } else {
        print("Follow list is empty or not found");
      }
    } catch (e) {
      print("Error loading followed user posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _followedUserPosts.length,
            itemBuilder: (context, index) {
              return PostWidget(
                postData: _followedUserPosts[index],
                onLikePressed: () {
                  // Handle like button press
                },
                onCommentPressed: () {
                  // Handle comment button press
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
