//singup
import 'package:flutter/material.dart';
import 'package:social_media_app/widgets/text_styles.dart';
import 'package:social_media_app/screens/login/signin.dart';
import 'package:social_media_app/services/auth_service.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController displayNameEditingController =
      new TextEditingController();
  TextEditingController nameEditingController = new TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Define _formKey here

  AuthService authMethods = AuthService(); // Initialize

  void signUp() {
    // Get the current state of the form
    final form = _formKey.currentState;

    // Validate the form
    if (form!.validate()) {
      String email = emailEditingController.text.trim();
      String password = passwordEditingController.text.trim();
      String name = nameEditingController.text.trim();

      // Call signUpWithEmailAndPassword from AuthMethods
      authMethods
          .registerWithEmailAndPassword(email, password, name)
          .then((result) {
        // Handle successful sign up, navigate to another screen or show a success message
        print("Sign up successful for $name with email: $email");

        Navigator.pop(context);
      }).catchError((error) {
        // Handle sign up errors, show error message or handle differently based on error
        print("Sign up failed: $error");
      });
    }
  }

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        elevation: 0.0,
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Spacer(),
            Form(
              key: _formKey, // Associate _formKey with Form widget

              child: Column(
                children: [
                  TextFormField(
                    controller: nameEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Add email format validation if necessary
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordEditingController,
                    obscureText: true,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Password"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isPressed = true; // Set the button press state to true
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isPressed = false; // Set the button press state to false
                });
                signUp(); // Perform the sign-up action
              },
              onTapCancel: () {
                setState(() {
                  _isPressed =
                      false; // Reset the button press state if the tap is cancelled
                });
              },
              child: AnimatedContainer(
                duration:
                    Duration(milliseconds: 100), // Optional: Animation duration
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors:
                        _isPressed // Change gradient colors based on button press state
                            ? [
                                Color.fromARGB(255, 244, 191, 0),
                                Color.fromARGB(255, 86, 188, 42),
                              ]
                            : [
                                const Color(0xff007EF4),
                                Color.fromARGB(255, 86, 188, 42),
                              ],
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Sign Up",
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: simpleTextStyle(),
                  ),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: Color.fromARGB(255, 32, 72, 158),
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
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
