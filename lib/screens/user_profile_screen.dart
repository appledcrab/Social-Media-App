//user profile screen
//profile of a user

/*
Showing users profile picture, and short description of themself
Option to edit their own profile
Look through the users posts
*/
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String profileImageUrl;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(profileImageUrl),
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 20),
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Add more profile information here
          ],
        ),
      ),
    );
  }
}
