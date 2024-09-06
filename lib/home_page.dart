import 'package:banky/pages/add_funds_page.dart';
import 'package:banky/pages/transfer_page.dart';
import 'package:banky/pages/withdraw_page.dart';
import 'package:banky/scan_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'CreditCardManager.dart';
import 'loginsignup/LoginScreen.dart'; // For charts

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4.0,
        leading: const Icon(Icons.account_balance, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccountOverview(),
            const SizedBox(height: 20),
            _buildManageCards(context),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Widget _buildAccountOverview() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No data available', style: TextStyle(fontFamily: 'SF Pro', fontSize: 16)));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        double balance = userData['balance']?.toDouble() ?? 0.0;
        String displayName = userData['displayName'] ?? 'User';
        String profileImage = userData['pdp'] ?? '';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileAndBalanceSection(displayName, profileImage, balance),
              const SizedBox(height: 20),
              _buildActionsSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAndBalanceSection(String displayName, String profileImage, double balance) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade100, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
            radius: 40,
            child: profileImage.isEmpty ? Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Account Balance',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickActionButton(
          CupertinoIcons.arrow_right_arrow_left,
          'Transfer',
              () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => TransferPage()),
          ),
        ),
        _quickActionButton(
          CupertinoIcons.plus_circled,
          'Add Funds',
              () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => AddFundsPage()),
          ),
        ),
        _quickActionButton(
          CupertinoIcons.money_dollar_circle,
          'Withdraw',
              () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => WithdrawPage()),
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16), // Increased padding
            child: Icon(icon, color: Colors.teal.shade800, size: 30),
          ),
          onPressed: onPressed,
        ),
        const SizedBox(height: 8), // Adjusted spacing
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 16, // Slightly larger font size
            fontWeight: FontWeight.w600, // Slightly bolder font weight
            color: Colors.teal.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildManageCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => CreditCardManagerPage()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(4, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Card Settings',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    splashColor: Colors.tealAccent.shade100.withOpacity(0.3),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => CreditCardManagerPage()),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.teal.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.creditcard, color: Colors.white, size: 24),
                          const SizedBox(width: 14),
                          const Text(
                            'Go to Card Manager',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
