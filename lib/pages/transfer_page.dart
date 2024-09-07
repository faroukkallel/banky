import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _amountController = TextEditingController();
  String? _recipientAccount;
  bool _isProcessing = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission is required to scan QR codes.')),
      );
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (qrController != null) {
      if (Platform.isAndroid) {
        qrController!.pauseCamera();
      } else if (Platform.isIOS) {
        qrController!.resumeCamera();
      }
    }
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _amountController.clear();
      _recipientAccount = null;
      _isProcessing = false;
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    qrController?.scannedDataStream.listen((scanData) async {
      final uid = scanData.code;

      if (uid != null) {
        try {
          final recipientDoc = FirebaseFirestore.instance.collection('users').doc(uid);
          final recipientSnapshot = await recipientDoc.get();

          if (recipientSnapshot.exists) {
            final recipientData = recipientSnapshot.data();
            final email = recipientData?['email'] as String?;

            setState(() {
              _recipientAccount = email;
            });
          } else {
            _showErrorDialog('Recipient account not found.');
          }
        } catch (e) {
          _showErrorDialog('Failed to fetch recipient details: ${e.toString()}');
        }

        qrController?.pauseCamera(); // Optionally stop scanning after obtaining the code
      }
    }).onError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan QR code. Please try again.')),
      );
    });
  }

  Future<void> _checkBalanceAndTransfer() async {
    final amount = int.tryParse(_amountController.text) ?? 0;

    if (_recipientAccount == null || amount <= 0) {
      _showErrorDialog('Invalid input. Please check the recipient and amount.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
    final recipientQuery = FirebaseFirestore.instance.collection('users')
        .where('email', isEqualTo: _recipientAccount);

    try {
      final userSnapshot = await userDoc.get();
      if (!userSnapshot.exists) {
        _showErrorDialog('Sender account not found.');
        return;
      }

      final recipientSnapshot = await recipientQuery.get();
      if (recipientSnapshot.docs.isEmpty) {
        _showErrorDialog('Recipient account not found.');
        return;
      }

      final recipientDoc = recipientSnapshot.docs.first;
      final recipientData = recipientDoc.data();
      final recipientUid = recipientDoc.id;

      final currentBalance = (userSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      if (currentBalance < amount) {
        _showErrorDialog('Insufficient funds.');
        return;
      }

      // Update sender's balance
      final newBalance = currentBalance - amount;
      await userDoc.update({'balance': newBalance});

      // Update recipient's balance
      final recipientBalance = (recipientData['balance'] as num?)?.toDouble() ?? 0.0;
      final newRecipientBalance = recipientBalance + amount;
      await FirebaseFirestore.instance.collection('users').doc(recipientUid).update({'balance': newRecipientBalance});

      // Record the transaction in Firestore
      await _addTransactionToFirestore(amount, recipientUid);

      _showSuccessDialog(amount);
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (_isProcessing) {
        setState(() {
          _isProcessing = false;
        });
      }

      // Resume the camera if it's paused
      qrController?.resumeCamera();
    }
  }

  Future<void> _addTransactionToFirestore(int amount, String recipientUid) async {
    try {
      // Reference to Firestore
      final firestore = FirebaseFirestore.instance;

      // Document reference (assuming you are storing transactions in a collection named 'transactions')
      final transactionDoc = firestore.collection('transactions').doc();

      // Get the current user's UID
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Add transaction details to Firestore
      await transactionDoc.set({
        'amount': amount.toDouble(),
        'type': 'transfer', // Indicates this is a transfer
        'date': Timestamp.now(),
        'description': 'Funds transferred to $recipientUid',
        'userId': uid, // Include user ID for reference
        'recipientId': recipientUid, // Include recipient user ID for reference
      });
    } catch (e) {
      // Handle any errors that occur during Firestore operations
      print('Error adding transaction to Firestore: $e');
    }
  }

  void _showSuccessDialog(int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success', style: TextStyle(color: Colors.green)),
        content: Text('Successfully transferred \$${amount.toStringAsFixed(2)} to account $_recipientAccount.'),
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.pop(context);
              _resetState();  // Reset the state after success dialog is dismissed
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    // Log the error message to the console
    print('Error: $message');

    // Show the error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer Funds'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blueAccent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Recipient Email: ${_recipientAccount ?? 'Not Scanned'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on, color: Colors.blueAccent),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _checkBalanceAndTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isProcessing
                      ? CircularProgressIndicator()
                      : Text('Transfer'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
