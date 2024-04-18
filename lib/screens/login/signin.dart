//sign in

import 'package:flutter/material.dart';
import 'package:social_media_app/widgets/text_styles.dart';
import 'package:social_media_app/screens/login/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/screens/bottom_nav.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();

  AuthService authMethods = AuthService(); // Initialize

  final _formKey = GlobalKey<FormState>();

  void signIn() {
    final form = _formKey.currentState;
    if (form == null) {
      print("Form state is null");
      return;
    }

    String email = emailEditingController.text.trim();
    String password = passwordEditingController.text.trim();

    if (form.validate()) {
      if (authMethods == null) {
        print("AuthMethods instance is null");
        return;
      }

      authMethods.signInWithEmailAndPassword(email, password).then((result) {
        // Handle successful sign in, navigate to another screen or show a success message
        print("Sign in successful for $email");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      }).catchError((error) {
        print("Sign in failed: $error");
        // Show error message to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(error.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        elevation: 0.0,
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Spacer(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("email"),
                    validator: (val) {
                      return val!.isEmpty || !val.contains('@')
                          ? "Enter valid email"
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: passwordEditingController,
                    obscureText: true,
                    validator: (val) {
                      return val!.length >= 6
                          ? null
                          : "Enter Password 5+ characters";
                    },
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("password"),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                // Sign in
                signIn();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff007EF4),
                        Color.fromARGB(255, 86, 188, 42)
                      ],
                    )),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Sign In",
                  style: biggerTextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                // Navigate to SignUp screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have account? ",
                    style: simpleTextStyle(),
                  ),
                  Text(
                    "Register now",
                    style: TextStyle(
                        color: Color.fromARGB(255, 32, 72, 158),
                        fontSize: 16,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
