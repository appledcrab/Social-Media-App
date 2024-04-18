import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//This function fetches the user data from Firestore using the user's ID
  Future<Map<String, dynamic>> getUserData(String userID) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userID).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {}; // Return an empty map if user document doesn't exist
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {}; // Return an empty map in case of error
    }
  }
}
