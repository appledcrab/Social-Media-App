import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatService {
  Future<void> createDirectChat(types.User otherUser) async {
    try {
      final room = await FirebaseChatCore.instance.createRoom(otherUser);
      print('Direct chat room created successfully: ${room.id}');
    } catch (e) {
      print('Error creating direct chat room: $e');
    }
  }
}
