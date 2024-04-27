import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditPostScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  EditPostScreen({required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.post['content'];
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImageFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }

  void _savePost() async {
    final String newContent = _contentController.text.trim();
    String? imageUrl;

    if (newContent.isNotEmpty) {
      try {
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('post_images')
              .child(widget.post['id'] + '.jpg');
          await ref.putFile(_pickedImage!);
          imageUrl = await ref.getDownloadURL();
        }

        Map<String, dynamic> updatedPostData = {
          'content': newContent,
          if (imageUrl != null) 'imageUrl': imageUrl,
        };

        await FirebaseFirestore.instance
            .collection('test')
            .doc(widget.post['id'])
            .update(updatedPostData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.of(context).pop(true);
      } on FirebaseException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: ${error.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Content cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
              ),
            ),
            SizedBox(height: 20),
            _buildImageButton(),
            if (_pickedImage != null) Image.file(_pickedImage!)
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton() {
    return OutlinedButton(
      onPressed: _pickImage,
      child: Text('Change Image'),
    );
  }
}


  // void _savePost() async {
  //   final String newContent = _contentController.text.trim();
  //   if (newContent.isNotEmpty) {
  //     try {
  //       print("Updating post with ID: ${widget.post['id']}");
  //       await FirebaseFirestore.instance
  //           .collection('test') // Ensure this is the correct collection
  //           .doc(widget.post['id']) // Ensure the ID is correct
  //           .update({'content': newContent});
  //       print("Post updated successfully.");
  //       Navigator.of(context)
  //           .pop(true); // Go back with a result indicating success
  //     } on FirebaseException catch (error) {
  //       print("Failed to update post: ${error.message}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to update post: ${error.message}')),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Content cannot be empty')),
  //     );
  //   }
  // }
