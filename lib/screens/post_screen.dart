//for creating and (maybe?) editing posts
/*
Allow users to create new posts with text, images, or links.
(maybe)Provide options to add hashtags to posts.
(maybe) Enable editing of posts after they have been published.
*/
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For image uploads
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Import this at the top of your Dart file

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State {
  final TextEditingController _contentController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _submitPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter some text for your post.")));
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImageToFileStorage(_imageFile!);
    }

    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    FirebaseFirestore.instance.collection('test').add({
      'content': _contentController.text,
      'imageUrl': imageUrl,
      'created': FieldValue.serverTimestamp(),
      'author_id': userId,
      'likes': 0,
    }).then((docRef) {
      _contentController.clear();
      setState(() {
        _imageFile = null;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Post created!")));
      //instead of navigating, going to clear the text field and image field
      _contentController.clear();
    }).catchError((error) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create post: $error")));
    });
  }

  Future<String> _uploadImageToFileStorage(XFile file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('posts/${file.name}');
    UploadTask uploadTask = ref.putFile(File(file.path));
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_imageFile != null)
              Image.file(File(_imageFile!.path),
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _pickImage,
              child: Text('Pick an Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
