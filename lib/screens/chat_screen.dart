import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
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
              user: types.User(id: user!.uid),
            );
          }
        },
      ),
    );
  }
}
