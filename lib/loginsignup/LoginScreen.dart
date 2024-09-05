import 'dart:developer';
import 'package:banky/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/colors.dart';
import '../utils/common_Button.dart';
import 'SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoggingIn = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return;

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        String? fcmToken;
        final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        fcmToken = await _firebaseMessaging.getToken();
        final usersRef = FirebaseFirestore.instance.collection('users');
        final snapshot = await usersRef.doc(user.uid).get();

        if (!snapshot.exists) {
          await usersRef.doc(user.uid).set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'FCMtoken': fcmToken,
            'creditCardSaved': [],             // Initialize with empty list
            'balance': 0,                      // Initialize balance with 0
            'transactionHistory': [],          // Initialize with empty list
          });
        }

        await usersRef.doc(user.uid).set({
          'FCMtoken': fcmToken,
        }, SetOptions(merge: true));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
      }

      setState(() {
        _isLoggingIn = false;
      });
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
      });
      log('Google Sign-In failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    }
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = authResult.user;

      if (user != null) {
        String? fcmToken;
        final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        fcmToken = await _firebaseMessaging.getToken();
        final usersRef = FirebaseFirestore.instance.collection('users');
        final snapshot = await usersRef.doc(user.uid).get();

        if (!snapshot.exists) {
          await usersRef.doc(user.uid).set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'FCMtoken': fcmToken,
            'creditCardSaved': [],             // Initialize with empty list
            'balance': 0,                      // Initialize balance with 0
            'transactionHistory': [],          // Initialize with empty list
          });
        }

        await usersRef.doc(user.uid).set({
          'FCMtoken': fcmToken,
        }, SetOptions(merge: true));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
      }

      setState(() {
        _isLoggingIn = false;
      });
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
      });
      log('Email Sign-In failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email Sign-In failed: $e')),
      );
    }
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  Future<void> _forgotPassword(BuildContext context) async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      log('Password reset email sending failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sending failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg_login.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.bottomCenter,
                begin: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6), // Adjust opacity
                  Colors.grey.shade900.withOpacity(0.6),
                  Colors.grey.shade700.withOpacity(0.6),
                  Colors.grey.shade700.withOpacity(0.6),
                  Colors.grey.shade900.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white), // Set label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Set border color to white when the field is enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Set border color to white when the field is focused
                        ),
                        // Customize other InputDecoration properties as needed
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white), // Set text color to white
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white), // Set label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Set border color to white when the field is enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Set border color to white when the field is focused
                        ),
                        // Customize other InputDecoration properties as needed
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextButton(
                        onPressed: () {
                          _forgotPassword(context);
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CommonButton(
                              border: Border.all(color: AppColor.white_Color),
                              text: "Login",
                              onTap: () {
                                _signInWithEmailAndPassword(context);
                              },
                              textStyle: const TextStyle(fontFamily: "Rubik", fontSize: 14, color: AppColor.white_Color),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: CommonButton(
                              border: Border.all(color: AppColor.white_Color),
                              text: "Sign Up",
                              onTap: () {
                                _navigateToSignUp(context);
                              },
                              textStyle: const TextStyle(fontFamily: "Rubik", fontSize: 14, color: AppColor.white_Color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60), // Adjust spacing between email/password section and Google login button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CommonButton(
                  border: Border.all(color: AppColor.white_Color),
                  text: "Login with Google",
                  onTap: () {
                    _signInWithGoogle(context);
                  },
                  textStyle: const TextStyle(fontFamily: "Rubik", fontSize: 14, color: AppColor.white_Color),
                ),
              ),
            ],
          ),
          if (_isLoggingIn)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.white_Color),
              ),
            ),
        ],
      ),
    );
  }
}