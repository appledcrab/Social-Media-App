//authentication service to handle user authentication
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:social_media_app/screens/login/signin.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  // Register with email and password
  // Future<UserCredential> registerWithEmailAndPassword(
  //     String email, String password) async {
  //   try {
  //     UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);

  //     // Create user document in Firestore
  //     await _createUserDocument(userCredential.user!.uid);

  //     return userCredential;
  //   } catch (e) {
  //     print(e.toString());
  //     throw e;
  //   }
  // }
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Create or update the user in both Firestore and flutter_chat_core
      if (userCredential.user != null) {
        await _createOrUpdateChatUser(userCredential.user!, username);
      }
      return userCredential;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> _createOrUpdateChatUser(User user, String username) async {
    final userData = {
      'createdAt': FieldValue.serverTimestamp(),
      'bio': "I'm new here! Say hi!",
      'photoUrl':
          'https://firebasestorage.googleapis.com/v0/b/social-media-app-988e8.appspot.com/o/app_assets%2Fdefault.jpg?alt=media',
      'displayName': username, // This can be any name the user chooses
    };

    // Create user document in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userData);

    // Update the chat user data for flutter_chat_core
    final chatUser = types.User(
      id: user.uid,
      firstName: userData['displayName']
          as String?, // Use displayName or split part of it if needed
      imageUrl: userData['photoUrl'] as String?,
      metadata: {'bio': userData['bio']},
    );

    // Use flutter_chat_core to update the user information
    await FirebaseChatCore.instance.createUserInFirestore(chatUser);
  }

  // Sign out
  Future<void> signOut(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                print("Sign out button should have showed up and pressed");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  // Get current user
  //Can be used to check if user is signed in or not
  //if it returns null, user is not signed in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

//These work off given user already (firebase user object) - really tired when i added this I dont remember when to use.
  String getUserID(user) {
    return user.uid;
  }

  //This creates a user document in the 'users' collection with the user's ID as the document ID
  Future<void> _createUserDocument(String uid) async {
    final _firestore = FirebaseFirestore.instance;
    try {
      await _firestore.collection('users').doc(uid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'bio': "I'm new here! Say hi!",
        'photoUrl':
            'https://firebasestorage.googleapis.com/v0/b/social-media-app-988e8.appspot.com/o/app_assets%2Fdefault.jpg?alt=media',
        'displayname': 'New User', //this is just a temp display name
      });
    } catch (e) {
      print('Error creating user document: $e');
      throw e;
    }
  }
}
