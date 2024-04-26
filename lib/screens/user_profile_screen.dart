import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:social_media_app/widgets/post_widget.dart';
import 'package:social_media_app/services/chat_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  ProfileScreen({Key? key, required this.userID}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _userPosts = [];
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserPosts();
  }

  final ChatService _chatService = ChatService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool get isCurrentUser => currentUser?.uid == widget.userID;

  Future<void> _fetchUserData() async {
    userData = await FirestoreService().getUserData(widget.userID);
    if (mounted) {
      setState(() {});
    }
  }

  void followUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user is signed in.");
      return;
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot = await transaction.get(userRef);

      if (!currentUserSnapshot.exists) {
        throw Exception("Current user not found!");
      }

      Map<String, dynamic> currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic>? metadata =
          currentUserData['metadata'] as Map<String, dynamic>?;
      List<dynamic> currentFollowList =
          metadata?['followList'] as List<dynamic>? ?? [];

      if (!currentFollowList.contains(widget.userID)) {
        currentFollowList.add(widget.userID);
        // Update only the followList within metadata to ensure atomic updates
        transaction.update(userRef, {'metadata.followList': currentFollowList});
        print("User followed successfully.");
      } else {
        print("Already following this user.");
      }
    }).catchError((error) {
      print("Failed to follow user: $error");
    });
  }

  Future<void> _fetchUserPosts() async {
    try {
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('test')
          .where('author_id', isEqualTo: widget.userID)
          .orderBy('created', descending: true)
          .get();
      _userPosts = postsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error loading user posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileScreen(userID: widget.userID),
                      ),
                    );
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () {
                    _chatService
                        .createDirectChat(types.User(id: widget.userID));
                  },
                ),
              ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (userData != null) _buildUserProfile(userData!),
            SizedBox(height: 20),
            _buildPostsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(Map<String, dynamic> userData) {
    String profileImageUrl = userData['imageUrl'] ??
        'https://firebasestorage.googleapis.com/v0/b/social-media-app-988e8.appspot.com/o/app_assets%2Fdefault.jpg?alt=media';
    String displayName = userData['firstName'] ?? 'No Name';
    String bio = userData['metadata']?['bio'] ?? 'No Bio Available';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 213, 233, 242),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 64,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          SizedBox(height: 16),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            bio,
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 16),
          if (currentUser?.uid != widget.userID)
            ElevatedButton(
              onPressed: () {
                followUser();
              },
              //change this text based on if the user is already followed or not / is the user (not done yet)
              child: Text(
                'Follow',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      shrinkWrap: true, // Important to prevent infinite height error
      physics: NeverScrollableScrollPhysics(), // Disables scroll within scroll
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> post = _userPosts[index];
        return PostWidget(
          postData: post,
          onLikePressed: () {
// Handle like logic here
          },
          onCommentPressed: () {
// Handle comment logic here
          },
        );
      },
    );
  }
}
