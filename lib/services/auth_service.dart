//authentication service to handle user authentication

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
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
        'pfpUrl':
            'https://firebasestorage.googleapis.com/v0/b/social-media-app-988e8.appspot.com/o/app_assets%2Fdefault.jpg?alt=media',
        'username': 'New User', //this is just a temp display name
      });
    } catch (e) {
      print('Error creating user document: $e');
      throw e;
    }
  }
}
