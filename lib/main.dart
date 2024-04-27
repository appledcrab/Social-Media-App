import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:social_media_app/screens/bottom_nav.dart';
import 'package:social_media_app/screens/login/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/screens/bottom_nav.dart';
import 'package:social_media_app/screens/message_screen.dart';

// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:social_media_app/screens/post_screen.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseChatCore.instance.setConfig(
    const FirebaseChatCoreConfig(
      '[DEFAULT]',
      'rooms',
      'users',
    ),
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return MaterialApp(
            home: BottomNav(),
          );
        } else {
          return MaterialApp(
            title: 'Sign In',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: SignIn(),
          );
        }
      },
    );
  }
}
