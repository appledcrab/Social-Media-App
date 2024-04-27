import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/services/auth_service.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> postData;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEditPressed;
  final bool canEdit;

  PostWidget({
    Key? key,
    required this.postData,
    required this.onLikePressed,
    required this.onCommentPressed,
    this.onDeletePressed,
    this.onEditPressed,
    this.canEdit = false,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  List<Map<String, dynamic>> comments = [];

  int? likesCount;
  AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  void _handleLike() {
    // Increment the local state for immediate UI update adn the db
    setState(() {
      likesCount = (likesCount ?? 0) + 1;
    });

    FirebaseFirestore.instance
        .collection('test')
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

  void fetchComments() {
    FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: widget.postData['id'])
        .snapshots()
        .listen((data) {
      setState(() {
        comments =
            data.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        likesCount = widget.postData['likes'];
      });
    });
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
              future: AuthService().getUserData(widget.postData['author_id']),
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
            Divider(),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child:
              Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.comment),
              title: Text(comments[index]['text']),
              // subtitle: Text("by ${comments[index]['author_id']}"),
            );
          },
        ),
      ],
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
        if (widget.canEdit && widget.onEditPressed != null)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _handleEdit,
          ),
        if (widget.canEdit && widget.onDeletePressed != null)
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _handleDelete,
          ),
      ],
    );
  }
}
