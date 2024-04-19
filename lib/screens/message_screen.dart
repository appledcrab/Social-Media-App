import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'chat_screen.dart';

import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_media_app/services/chat_service.dart';
import 'package:social_media_app/widgets/text_styles.dart';

class RoomsPage extends StatelessWidget {
  RoomsPage({Key? key}) : super(key: key);

  ChatService _chatService = ChatService();

// SHould probably move this to a service file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
      ),
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  'Error: ${snapshot.error?.toString() ?? "Unknown error"}'),
            );
          } else {
            final List<types.Room> rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];

                Color roomsBackgroundColor =
                    Color.fromARGB(172, 222, 239, 255)!;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: roomsBackgroundColor,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(room.imageUrl ??
                            'https://firebasestorage.googleapis.com/v0/b/social-media-app-988e8.appspot.com/o/app_assets%2Fdefault.jpg?alt=media'), //default image if there is none.
                      ),
                      title: Text(
                        room.name!,
                        style: biggerTextStyle(),
                      ),
                      // subtitle: Text(room.id),
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ChatScreen(room: snapshot.data![index]),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),

      //testing to make a chatroom with a user - hardcoded.
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Replace `otherUser` with the user you want to start a chat with
      //     final otherUser = types.User(
      //       id: 'EcfpwGQEOHd6NgfDyMdeQuAqXCS2', // Replace with the actual user ID
      //     );
      //     _chatService.createDirectChat(otherUser);
      //   },
      //   child: Icon(Icons.chat),
      // ),
    );
  }
}
