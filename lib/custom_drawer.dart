// custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'extrapages/PrivacyPolicyPage.dart';
import 'extrapages/faq_page.dart';
import 'loginsignup/LoginScreen.dart';
import 'package:banky/pages/add_funds_page.dart';
import 'package:banky/pages/transfer_page.dart';
import 'package:banky/pages/withdraw_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: user == null
          ? Center(child: Text('No user signed in'))
          : FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data;
          final displayName = userData?['displayName'] ?? 'Username';
          final email = userData?['email'] ?? 'user@example.com';

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, size: 40, color: Colors.teal),
                    ),
                    SizedBox(height: 10),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.transfer_within_a_station),
                title: Text('Transfer'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransferPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Add Funds'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFundsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.money),
                title: Text('Withdraw'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WithdrawPage()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Language'),
                onTap: () {
                  // Show a dialog or navigate to a language selection page
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select Language'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text('English'),
                              onTap: () {
                                // Handle language change to English
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              title: Text('Spanish'),
                              onTap: () {
                                // Handle language change to Spanish
                                Navigator.of(context).pop();
                              },
                            ),
                            // Add more languages here
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.star),
                title: Text('Rate Us'),
                onTap: () {
                  // Open the app store or Google Play Store
                  // Replace with your app's store URL
                  const url = 'https://play.google.com/store/apps/details?id=com.example.yourapp';
                  launch(url); // Make sure to import `package:url_launcher/url_launcher.dart`
                },
              ),

              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share App'),
                onTap: () {
                  // Share the app link
                  const url = 'https://play.google.com/store/apps/details?id=com.example.yourapp';
                  Share.share('Check out this amazing app: $url'); // Make sure to import `package:share/share.dart`
                },
              ),

              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Privacy Policy'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                  );
                },
              ),


              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Feedback'),
                onTap: () {
                  // Navigate to a feedback page or open email client
                  // Example for opening email client
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'support@example.com',
                    queryParameters: {'subject': 'Feedback'},
                  );
                  launch(emailUri.toString()); // Make sure to import `package:url_launcher/url_launcher.dart`
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('FAQ'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FAQPage()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () => _signOut(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
