import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:social_media_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> postData;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEditPressed;

  PostWidget({
    Key? key,
    required this.postData,
    required this.onLikePressed,
    required this.onCommentPressed,
    this.onDeletePressed,
    this.onEditPressed,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late Future<Map<String, dynamic>?> userDataFuture;

  int? likesCount;

  @override
  void initState() {
    super.initState();
    userDataFuture = AuthService().getUserData(widget.postData['author_id']);
    likesCount = widget.postData['likes'] as int?;
  }

  void _handleLike() {
    // Increment the local state for immediate UI update adn the db
    setState(() {
      likesCount = (likesCount ?? 0) + 1;
    });

    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postData['id'])
        .update({'likes': FieldValue.increment(1)}).catchError(
            (e) => print('Error updating likes: $e'));
  }

  void _handleDelete() {
    if (widget.onDeletePressed != null) {
      widget.onDeletePressed!();
    }
  }

  void _handleEdit() {
    if (widget.onEditPressed != null) {
      widget.onEditPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data != null) {
                  return _buildPostHeader(snapshot.data!);
                } else {
                  return Text('Failed to load user data');
                }
              },
            ),
            SizedBox(height: 10),
            Text(
              widget.postData['content'],
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16),
            ),
            if (widget.postData['imageUrl'] != null)
              _buildPostImage(widget.postData['imageUrl']),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> userData) {
    DateTime postDate = (widget.postData['created'] as Timestamp)
        .toDate(); // Convert Timestamp to DateTime
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(userData['imageUrl']),
          radius: 20,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            userData['firstName'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Text(
          DateFormat('MMM d, yyyy').format(postDate),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPostImage(String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Image.network(image),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: _handleLike,
              ),
              Text(likesCount.toString()),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.comment),
          onPressed: widget.onCommentPressed,
        ),
        if (widget.onEditPressed != null)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _handleEdit,
          ),
        if (widget.onDeletePressed != null)
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _handleDelete,
          ),
      ],
    );
  }
}
