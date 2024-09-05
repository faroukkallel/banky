import 'package:banky/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isPrivacyChecked = false;

  Future<void> _signUpWithEmailAndPassword(BuildContext context) async {
    if (!_isPrivacyChecked) {
      setState(() {
        _errorMessage = "Please agree to our privacy policy.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

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
            'creditCardSaved': [], // Initialize as an empty list
            'transactionHistory': [], // Initialize as an empty list
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

    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Privacy Policy"),
          content: SingleChildScrollView(
            child: Text(
              // Your privacy policy text goes here
              "Privacy Policy\n\nWe are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our mobile application.\n\nInformation We Collect\nWe collect the following personal information to provide our services and improve user experience:\n- Name\n- Email address\n\nHow We Use Your Information\nWe use the collected information to:\n- Create and manage user accounts\n- Provide personalized services\n- Communicate with users\n- Improve our services and products\n\nData Protection\nWe take appropriate measures to safeguard your personal information from unauthorized access, disclosure, alteration, or destruction.\n\nWe Do Not Sell Your Information\nWe do not sell, trade, or otherwise transfer your personal information to third parties. Your information is solely used for the purposes stated in this Privacy Policy.\n\nNo Advertising Emails\nWe do not send advertising emails to our users. Your email address is only used for account-related communications and essential updates.\n\nBy using our mobile application, you consent to the collection and use of your personal information as described in this Privacy Policy.\n\nIf you have any questions or concerns about our Privacy Policy, please contact us at [ faroukkallelapps@gmail.com ].",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/login_bg_image.png"),
                fit: BoxFit.cover, // Change to cover for better display
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.bottomCenter,
                begin: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7), // Adjust opacity
                  Colors.grey.shade900.withOpacity(0.7),
                  Colors.grey.shade700.withOpacity(0.7),
                  Colors.grey.shade700.withOpacity(0.7),
                  Colors.grey.shade900.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.white), // Set text color to white
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.white), // Adjust icon color
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
                    prefixIcon: Icon(Icons.lock, color: Colors.white), // Adjust icon color
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
                Row(
                  children: [
                    Checkbox(
                      value: _isPrivacyChecked,
                      onChanged: (value) {
                        setState(() {
                          _isPrivacyChecked = value!;
                        });
                      },
                      checkColor: Colors.white, // Adjust color for better visibility
                      activeColor: Colors.green, // Adjust color for better visibility
                    ),
                    GestureDetector(
                      onTap: () {
                        _showPrivacyPolicyDialog(context);
                      },
                      child: Text(
                        "I agree to the privacy policy.",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _signUpWithEmailAndPassword(context),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text('Sign Up', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 10),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
