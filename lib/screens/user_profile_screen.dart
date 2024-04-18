import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  final String userID;
  final AuthService _auth = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

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
          return CircularProgressIndicator(); // Show loading indicator while fetching user data
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data;
            if (userData != null && userData.isNotEmpty) {
              // Grabs the user data from the snapshot - which is a map from the Firestore document users according to that user's ID
              //Using getUserData function from firestore_service.dart to deal with that.
              final profileImageUrl = userData['pfpUrl'];
              final username = userData['username'];

              return Scaffold(
                appBar: AppBar(
                  title: Text('Profile'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (profileImageUrl != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                      if (username != null) Text('Username: $username'),
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
