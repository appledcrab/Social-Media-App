import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Post {
  final String postId;
  final String authorId;
  final DateTime created;
  final String content;
  final String imageUrl;
  List<String> likes;

  Post({
    required this.postId,
    required this.authorId,
    required this.created,
    required this.content,
    required this.imageUrl,
    this.likes = const [],
  });

  // Converts Firestore document to Post object
  factory Post.fromJson(Map<String, dynamic> json, String docId) {
    return Post(
      postId: docId,
      authorId: json['author_id'] as String,
      created: (json['created'] as Timestamp).toDate(),
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      likes: List<String>.from(json['likes'] ?? []),
    );
  }

  // Converts Post object to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'author_id': authorId,
      'content': content,
      'created': created,
      'imageUrl': imageUrl,
      'likes': likes,
    };
  }

  // Methods to like and unlike the post
  void likePost(String userId) {
    if (!likes.contains(userId)) {
      likes.add(userId);
    }
  }

  void unlikePost(String userId) {
    likes.remove(userId);
  }
}
