import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCard extends StatefulWidget {
  final double totalPrice;

  PaymentCard({required this.totalPrice});

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  String? _paymentUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    final url = 'https://api.preprod.konnect.network/api/v2/payments/init-payment';
    final apiKey = '65032a1e47bb62fc99ba6f8c:HNJweJQNojhCIMZDnY'; // Replace with your API key
    final receiverWalletId = '65032a1e47bb62fc99ba6f90'; // Replace with your wallet ID

    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    };

    final body = jsonEncode({
      'receiverWalletId': receiverWalletId,
      'token': 'TND',
      'amount': (widget.totalPrice * 1000).toInt(), // Convert to Millimes
      'type': 'immediate',
      'acceptedPaymentMethods': ['bank_card', 'e-DINAR'],
      'lifespan': 15,
      'addPaymentFeesToAmount': false,
      'theme': 'light',
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _paymentUrl = responseData['payUrl'];
          _loading = false;
        });

        // Redirect to the payment URL
        if (_paymentUrl != null) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(
                  url: _paymentUrl!,
                  totalPrice: widget.totalPrice, // Pass the totalPrice
                ),
              ),
            );
          });
        }
      } else {
        throw Exception('Failed to initialize payment');
      }
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Text('Redirecting to payment page...'),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String url;
  final double totalPrice;

  WebViewPage({required this.url, required this.totalPrice});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

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
          // Ensure _processPayment is only called once
          if (url == 'https://gateway.sandbox.konnect.network/payment-success') {
            final user = FirebaseAuth.instance.currentUser;
            final uid = user?.uid;
            final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

            userRef.update({
              'balance': FieldValue.increment(widget.totalPrice.toInt()),
            });
            if (!_balanceUpdated) {
              await _processPayment();
              _balanceUpdated = true; // Set flag to prevent further updates
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

  void _showModernSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _processPayment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final paymentStatusRef = userRef.collection('payments').doc('latest'); // Use a fixed document ID for simplicity

        final paymentDoc = await paymentStatusRef.get();

        if (!paymentDoc.exists) {
          // Update the balance if payment status is not set
          await _updateBalance(userRef);

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
        final newBalance = currentBalance + widget.totalPrice.toInt();
        await userRef.update({'balance': newBalance});
      }
    } catch (error) {
      print('Error updating balance: $error');
    }
  }
}
