import 'package:flutter/material.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  final String userID;
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
              final profileImageUrl = userData['photoUrl'];
              final displayName = userData['displayName'];
              final bio = userData['bio'];

              return Scaffold(
                appBar: AppBar(
                  title: Text('Profile'),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileScreen(userID: userID)),
                          );
                        }),
                  ],
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
                      if (displayName != null)
                        Text('Display Name: $displayName'),
                      if (bio != null) Text('Bio: $bio'),
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
