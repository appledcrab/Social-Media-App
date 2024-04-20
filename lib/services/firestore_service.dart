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

//Reterns a list of all users in the Firestore database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    List<Map<String, dynamic>> userList = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').get();

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> userData = doc.data(); // Get the document data.
        userData['uid'] =
            doc.id; // Add the document ID as 'uid' to the user data map.

        userList.add(userData); // Add the modified user data to the list.
      });

      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      return []; // Returning empty list in error case.
    }
  }
}
