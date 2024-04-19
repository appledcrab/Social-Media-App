import 'package:flutter/material.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:social_media_app/services/chat_service.dart';

class ProfileScreen extends StatelessWidget {
  final String userID;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  ProfileScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _firestoreService.getUserData(userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data;
            if (userData != null && userData.isNotEmpty) {
              final profileImageUrl = userData['imageUrl'];
              final displayName = userData['firstName'];
              final bio = userData['metadata']?['bio'] as String?;

              User? currentUser = _authService.getCurrentUser();
              bool isCurrentUser =
                  currentUser != null && currentUser.uid == userID;

              return Scaffold(
                appBar: AppBar(
                  title: Text('Profile'),
                  actions: isCurrentUser
                      ? [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(userID: userID),
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
                                  .createDirectChat(types.User(id: userID));
                            },
                          ),
                        ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profileImageUrl != null)
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                      SizedBox(height: 16),
                      if (displayName != null)
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (bio != null)
                        Text(
                          bio,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      // Spacer(),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // if we were to add a follow feature, then heres a button
                        },
                        //change this text based on if the user is already followed or not / is the user
                        child: Text(
                          'Follow',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text("Put a list of posts here"),
                    ],
                  ),
                ),
              );
            } else {
              return Text('User not found');
            }
          }
        }
      },
    );
  }
}
