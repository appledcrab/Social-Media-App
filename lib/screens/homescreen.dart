// News feed from … community or following
// Infinite? Scroll of posts
// Being able to interact with posts

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/comment_screen.dart';
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

      if (followList.isNotEmpty) {
        // Setting up a real-time subscription to Firestore
        FirebaseFirestore.instance
            .collection('test') // Ensure this is your posts collection name
            .where('author_id', whereIn: followList)
            .orderBy('created', descending: true)
            .snapshots()
            .listen((snapshot) {
          List<Map<String, dynamic>> newPosts = snapshot.docs.map((doc) {
            return {
              'id': doc.id, // Include the Firestore document ID as 'id'
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();

          if (mounted) {
            setState(() {
              _followedUserPosts = newPosts;
            });
          }
        });
      } else {
        print("Follow list is empty or not found");
      }
    } catch (e) {
      print("Error setting up real-time post updates: $e");
    }
  }

  void _navigateToCommentScreen(String postId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentScreen(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _followedUserPosts.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> postData = _followedUserPosts[index];
              return PostWidget(
                postData: postData,
                onLikePressed: () {
                  // Handle like button press
                },
                onCommentPressed: () {
                  _navigateToCommentScreen(postData['id'].toString());
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
