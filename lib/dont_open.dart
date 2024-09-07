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
