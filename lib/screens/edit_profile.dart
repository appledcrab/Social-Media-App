import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/services/firestore_service.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String userID;

  EditProfileScreen({Key? key, required this.userID}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirestoreService _firestoreService = FirestoreService();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      var snapshot = await _firestoreService.getUserData(widget.userID);
      if (snapshot != null) {
        Map<String, dynamic> userData = snapshot;
        _displayNameController.text = userData['displayName'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        setState(() {
          _profileImageUrl = userData['photoUrl'];
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      try {
        TaskSnapshot snapshot = await _storage
            .ref()
            .child(
                'user/${widget.userID}/pfp') //overwrites the profile picture by putting it in the same place
            .putFile(imageFile);
        final String downloadURL = await snapshot.ref.getDownloadURL();
        setState(() {
          _profileImageUrl = downloadURL;
        });
      } catch (e) {
        print('Error uploading profile picture: $e');
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _firestore.collection('users').doc(widget.userID).update({
        'displayName': _displayNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'photoUrl': _profileImageUrl,
      });
      Navigator.pop(context); // Return to previous screen after profile update
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _uploadProfilePicture,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child:
                    _profileImageUrl == null ? Icon(Icons.add_a_photo) : null,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'displayName'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
