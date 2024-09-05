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

import 'loginsignup/LoginScreen.dart'; // For charts

class HomePage extends StatelessWidget {
  HomePage({super.key});

  List<FlSpot> _generateSampleData() {
    return [
      FlSpot(0, 0),
      FlSpot(1, 5),
      FlSpot(2, 3),
      FlSpot(3, 8),
      FlSpot(4, 6),
      FlSpot(5, 9),
    ];
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Banking Dashboard',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
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
          const SizedBox(width: 20), // Optional spacing between icons
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccountOverview(),
            const SizedBox(height: 20),
            _buildSpendingInsights(),
            const SizedBox(height: 20),
            _buildBalanceHistory(),
            const SizedBox(height: 20),
            _buildTransactionHistory(),
            const SizedBox(height: 20),
            _buildManageCards(),
            const SizedBox(height: 20),
            _buildScanCard(context),
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

        return CupertinoPageScaffold(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileAndBalanceSection(displayName, profileImage, balance),
                const SizedBox(height: 20),
                _buildActionsSection(context),
              ],
            ),
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
          colors: [CupertinoColors.systemGrey6, CupertinoColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(profileImage),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
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
                    color: CupertinoColors.black,
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
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_forward,
            color: CupertinoColors.systemGrey2,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey3,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(14),
            child: Icon(icon, color: CupertinoColors.activeBlue, size: 26),
          ),
          onPressed: onPressed,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Insights',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: _showingSections(),
                      centerSpaceRadius: 45,
                      sectionsSpace: 4,
                      startDegreeOffset: 180,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (touchEvent, pieTouchResponse) {
                          // Implement interaction or tooltip functionality here
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return [
      PieChartSectionData(
        color: Colors.teal.shade600,
        value: 40,
        title: '40%',
        radius: 55,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.teal.shade400,
        value: 30,
        title: '30%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.teal.shade200,
        value: 20,
        title: '20%',
        radius: 45,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.teal.shade100,
        value: 10,
        title: '10%',
        radius: 40,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('Groceries', Colors.teal.shade600),
        _buildLegendItem('Bills', Colors.teal.shade400),
        _buildLegendItem('Entertainment', Colors.teal.shade200),
        _buildLegendItem('Other', Colors.teal.shade100),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade900,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBalanceHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance History',
            style: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ).navTitleTextStyle,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSampleData(),
                      isCurved: true,
                      color: CupertinoColors.systemTeal,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: CupertinoColors.systemTeal.withOpacity(0.3),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Automatically get the current user's UID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return Center(child: Text('No transactions available'));
        }

        // Retrieve the transactionHistory array from the document
        var data = snapshot.data!.data() as Map<String, dynamic>;
        var transactions = data['transactionHistory'] as List<dynamic>?;

        if (transactions == null || transactions.isEmpty) {
          return Center(child: Text('No transactions available'));
        }

        // Map the transactions to ListTile widgets
        var transactionWidgets = transactions.map((transaction) {
          return ListTile(
            leading: Icon(Icons.monetization_on, color: Colors.teal),
            title: Text(transaction['description'] ?? 'Transaction'),
            subtitle: Text(transaction['category'] ?? 'Category'),
            trailing: Text(
              '${transaction['amount'] ?? 0}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactionWidgets.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[200]),
                  itemBuilder: (context, index) => transactionWidgets[index],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManageCards() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Replace 'current_uid' with actual UID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No data available'));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        var cards = userData['creditCardSaved'] as List<dynamic>? ?? [];

        var cardWidgets = cards.map((card) {
          var cardData = card as Map<String, dynamic>;
          return ListTile(
            leading: Icon(Icons.credit_card, color: Colors.teal),
            title: Text(cardData['cardNumber'] ?? '**** **** **** 0000'),
            subtitle: Text(cardData['cardHolder'] ?? 'Card Holder'),
            trailing: Icon(Icons.edit, color: Colors.teal),
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Cards',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cardWidgets.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
                  itemBuilder: (context, index) => cardWidgets[index],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Card',
            style: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ).navTitleTextStyle,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(CupertinoIcons.camera, color: CupertinoColors.systemTeal, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Use the camera to scan your card details',
                    textAlign: TextAlign.center,
                    style: CupertinoTextThemeData(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ).textStyle,
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton.filled(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => ScanPage()),
                      );
                    },
                    child: Text(
                      'Scan Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
