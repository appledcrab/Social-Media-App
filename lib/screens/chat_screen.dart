import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:social_media_app/screens/user_profile_screen.dart';
import 'package:social_media_app/services/auth_service.dart';

class ChatScreen extends StatelessWidget {
  final types.Room room;

  const ChatScreen({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: StreamBuilder<List<types.Message>>(
        stream: FirebaseChatCore.instance.messages(room),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No messages yet"));
          } else {
            final List<types.Message> messages = snapshot.data!;
            return Chat(
              messages: messages,
              onSendPressed: (partialMessage) {
                FirebaseChatCore.instance.sendMessage(
                  partialMessage,
                  room.id,
                );
              },
              onMessageLongPress: (context, p1) =>
                  _showDeleteMessageDialog(context, p1),
              showUserNames: true,
              showUserAvatars: true,
              user: types.User(id: user!.uid),
              onAvatarTap: (user) {
                // tapping on avatar opens their profile
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userID: user.id),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // confirming deleting message
  Future<void> _showDeleteMessageDialog(
      BuildContext context, types.Message message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Message?'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseChatCore.instance.deleteMessage(room.id, message.id);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
