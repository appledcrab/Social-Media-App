import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:social_media_app/screens/bottom_nav.dart';
import 'package:social_media_app/screens/login/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/screens/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'social-media-app-988e8',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseChatCore.instance.setConfig(
    const FirebaseChatCoreConfig(
      'social-media-app-988e8',
      'chat_rooms',
      'users',
    ),
  );

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
