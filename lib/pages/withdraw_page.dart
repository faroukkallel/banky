import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final List<String> _paymentMethods = ['Credit Card', 'PayPal', 'Bank Transfer'];
  String _selectedPaymentMethod = 'Select payment method';
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  User? _currentUser;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        await _fetchUserBalance();
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  Future<void> _fetchUserBalance() async {
    if (_currentUser == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);

    try {
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        setState(() {
          _balance = (userDoc['balance'] as double);
        });
      }
    } catch (e) {
      print('Error fetching user balance: $e');
    }
  }

  Future<void> _handleWithdraw(BuildContext context) async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      _showErrorDialog(context, 'Please enter an amount.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorDialog(context, 'Please enter a valid amount.');
      return;
    }

    if (_balance < amount) {
      _showErrorDialog(context, 'Insufficient balance.');
      return;
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);

    try {
      // Deduct amount
      final newBalance = _balance - amount;
      await userDocRef.update({'balance': newBalance});

      // Record the transaction in Firestore
      await _addTransactionToFirestore(amount);

      // Update local balance
      setState(() {
        _balance = newBalance;
      });

      _showSuccessDialog(context, 'Withdrawal successful.');
    } catch (e) {
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  Future<void> _addTransactionToFirestore(double amount) async {
    try {
      // Reference to Firestore
      final firestore = FirebaseFirestore.instance;

      // Document reference (assuming you are storing transactions in a collection named 'transactions')
      final transactionDoc = firestore.collection('transactions').doc();

      // Get the current user's UID
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Add transaction details to Firestore
      await transactionDoc.set({
        'amount': amount,
        'type': 'withdrawal', // Indicates this is a withdrawal
        'date': Timestamp.now(),
        'description': 'Withdrawn \$${amount.toStringAsFixed(2)}',
        'userId': uid, // Include user ID for reference
      });
    } catch (e) {
      // Handle any errors that occur during Firestore operations
      print('Error adding transaction to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Funds'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Show information about the withdrawal process
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Amount'),
            _buildAmountInputField(),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Payment Method'),
            _buildPaymentMethodField(context),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _buttonAnimation,
              child: _buildWithdrawButton(context),
            ),
            SizedBox(height: 20),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white, size: 36),
          radius: 30,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentUser?.displayName ?? 'John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Available Balance: \$${_balance.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAmountInputField() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '\$',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          hintText: 'Enter amount',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPaymentMethodPicker(context);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: _selectedPaymentMethod,
              hintStyle: TextStyle(color: Colors.grey[600]),
              suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _paymentMethods.map((method) {
          return ListTile(
            title: Text(method),
            onTap: () {
              setState(() {
                _selectedPaymentMethod = method;
              });
              Navigator.pop(context);
            },
          );
        }).toList()
          ..add(
            ListTile(
              title: Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    return ElevatedButton(
      child: Text('Withdraw'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.0),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () => _handleWithdraw(context),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        'Ensure you have sufficient balance before withdrawing. Funds will be processed within 2-3 business days.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
          ),
        ],
      ),
    );
  }
}
