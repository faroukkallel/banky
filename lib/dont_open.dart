class _WebViewPageState extends State<WebViewPage> {
  bool _balanceUpdated = false; // Track if balance has been updated

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment View'),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (String url) async {
          if (url == 'https://gateway.sandbox.konnect.network/payment-success') {
            if (!_balanceUpdated) {
              await _processPayment(); // Only call once
              _balanceUpdated = true; // Set the flag to prevent further updates
            }
            _showModernSnackBar(context, 'Payment was successful!', Colors.green);
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context); // Close the WebView page
            });
          } else if (url == 'https://gateway.sandbox.konnect.network/payment-failure') {
            _showModernSnackBar(context, 'Payment has failed.', Colors.red);
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context); // Close the WebView page
            });
          }
        },
      ),
    );
  }

  Future<void> _processPayment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final paymentStatusRef = userRef.collection('payments').doc('latest');

        final paymentDoc = await paymentStatusRef.get();

        // Only update if the payment status is not already set to completed
        if (!paymentDoc.exists || paymentDoc.data()?['status'] != 'completed') {
          await _updateBalance(userRef); // Update balance
          // Set payment status to completed
          await paymentStatusRef.set({
            'status': 'completed',
            'amount': widget.totalPrice,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (error) {
      print('Error processing payment: $error');
    }
  }

  Future<void> _updateBalance(DocumentReference userRef) async {
    try {
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        // Cast the data to Map<String, dynamic>
        final data = userDoc.data() as Map<String, dynamic>;
        final currentBalance = data['balance'] ?? 0;
        final newBalance = currentBalance + widget.totalPrice.toInt(); // Update balance
        await userRef.update({'balance': newBalance}); // Ensure this updates correctly
      }
    } catch (error) {
      print('Error updating balance: $error');
    }
  }
}
