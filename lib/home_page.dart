import 'package:banky/pages/add_funds_page.dart';
import 'package:banky/pages/transfer_page.dart';
import 'package:banky/pages/withdraw_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CreditCardManager.dart';
import 'custom_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.account_balance, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the custom drawer on tap
            },
          ),
        ),
        actions: [
          const SizedBox(width: 20),
        ],
      ),
      drawer: CustomDrawer(), // Attach the CustomDrawer
      body: Column(
        children: [
          Expanded(child: _buildAccountOverview(context)),
          Flexible(child: _buildManageCards(context)),
          Flexible(child: _buildTransactionHistory(context)),
        ],
      ),
    );
  }

  Widget _buildAccountOverview(BuildContext context) { // Accept context as a parameter
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('No data available',
                style: TextStyle(fontFamily: 'SF Pro', fontSize: 16)),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        double balance = userData['balance']?.toDouble() ?? 0.0;
        String displayName = userData['displayName'] ?? 'User';
        String profileImage = userData['pdp'] ?? '';

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: SizedBox.expand(
            child: _buildProfileAndBalanceSection(
                displayName, profileImage, balance, context), // Pass context
          ),
        );
      },
    );
  }

  Widget _buildProfileAndBalanceSection(
      String displayName, String profileImage, double balance, BuildContext context) { // Accept context here
    return Container(
      padding: const EdgeInsets.all(5.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          _buildActionsSection(context), // Pass context here
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _quickActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Icon(icon, color: Colors.teal.shade800, size: 30),
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
        child: SizedBox.expand(
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    splashColor: Colors.tealAccent.shade100.withOpacity(0.3),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CreditCardManagerPage()),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.creditcard,
                              color: Colors.white, size: 24),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No transactions available',
                style: TextStyle(fontFamily: 'SF Pro', fontSize: 16)),
          );
        }

        var transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index].data() as Map<String, dynamic>;
            String type = transaction['type'];
            double amount = transaction['amount'];
            String description = transaction['description'];
            DateTime date = (transaction['date'] as Timestamp).toDate();

            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              leading: Icon(
                type == 'withdrawal'
                    ? CupertinoIcons.minus_circle
                    : type == 'addition'
                    ? CupertinoIcons.plus_circle
                    : CupertinoIcons.creditcard,
                color: type == 'withdrawal'
                    ? Colors.red
                    : type == 'addition'
                    ? Colors.green
                    : Colors.blue,
              ),
              title: Text(description),
              subtitle: Text('${date.toLocal()}'),
              trailing: Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: type == 'withdrawal' ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
