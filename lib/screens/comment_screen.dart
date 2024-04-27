import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitComment() async {
    final String commentText = _commentController.text.trim();
    final User? user = FirebaseAuth.instance.currentUser;

    if (commentText.isEmpty || user == null) {
      // Either the text is empty or user is null
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('comments').add({
        'postId': widget.postId,
        'text': commentText,
        'author': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear the text field and dismiss the keyboard
      _commentController.clear();
      FocusScope.of(context).unfocus();

      // Optional: Pop the screen to return to the post after commenting
      Navigator.of(context).pop();
    } catch (e) {
      // Show an error message if something goes wrong
      if (kDebugMode) {
        print('Failed to submit comment: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit comment.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Comment')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: "Write a comment..."),
            ),
            ElevatedButton(
              onPressed: _submitComment,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
