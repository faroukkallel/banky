import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../PaymentCard.dart';

class AddFundsPage extends StatefulWidget {
  @override
  _AddFundsPageState createState() => _AddFundsPageState();
}

class _AddFundsPageState extends State<AddFundsPage> {
  int? totalPrice; // Variable to store the selected amount
  TextEditingController _customAmountController = TextEditingController(); // Controller for custom amount

  String? selectedPaymentMethod; // Variable to store selected payment method

  List<String> paymentMethods = ['Credit Card'];

  bool _isProcessing = false; // Boolean to track payment processing


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Funds'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Select Amount to Add'),
              SizedBox(height: 10),
              _buildAmountOptions(context),
              SizedBox(height: 20),
              _buildCustomAmountField(),
              SizedBox(height: 30),
              _buildPaymentMethodDropdown(),
              SizedBox(height: 30),
              _buildSectionHeader(context, 'Receive Funds via QR Code'),
              SizedBox(height: 10),
              _buildQRCodeOption(),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: _isProcessing
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(
                    'Add Funds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _isProcessing
                      ? null // Disable the button if already processing
                      : () {
                    if (totalPrice != null && totalPrice! > 0) {
                      _handleAddFunds();
                    } else {
                      // Show an alert if no amount is selected
                      _showErrorDialog();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddFunds() {
    setState(() {
      _isProcessing = true; // Set processing state to true
    });

    _showProcessingDialog(context, totalPrice!);

    Future.delayed(Duration(seconds: 2), () async {
      await _addTransactionToFirestore(totalPrice!);
      Navigator.of(context).pop(); // Close the dialog

      setState(() {
        _isProcessing = false; // Set processing state to false
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCard(
            totalPrice: totalPrice!.toDouble(),
          ),
        ),
      );
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text('Please select or enter an amount to add.'),
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

  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your payment method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            _showPaymentMethodPicker();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedPaymentMethod ?? 'Select Payment Method',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
            children: [
              Expanded(
                child: Center( // Center the ListView
                  child: ListView.builder(
                    shrinkWrap: true, // Ensures ListView doesn't take up more space than necessary
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Center( // Center the text inside the ListTile
                          child: Text(
                            paymentMethods[index],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedPaymentMethod = paymentMethods[index];
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildAmountOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAmountCard(context, '€10', 10),
        _buildAmountCard(context, '€20', 20),
        _buildAmountCard(context, '€50', 50),
        _buildAmountCard(context, '€100', 100),
      ],
    );
  }

  Widget _buildAmountCard(BuildContext context, String amount, int value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          totalPrice = value; // Set the selected amount
          _customAmountController.text = value.toString(); // Set the custom amount field
        });
      },
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: totalPrice == value ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(amount, style: TextStyle(fontSize: 16, color: Colors.black)),
        ),
      ),
    );
  }

  Widget _buildCustomAmountField() {
    return TextField(
      controller: _customAmountController, // Attach the controller
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.monetization_on, color: Colors.grey),
        hintText: 'Enter custom amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          totalPrice = int.tryParse(value); // Update the custom amount
        });
      },
    );
  }

  Widget _buildQRCodeOption() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data: FirebaseAuth.instance.currentUser!.uid,
              version: QrVersions.auto,
              size: 180.0,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Share this QR code to receive funds',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProcessingDialog(BuildContext context, int totalPrice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Processing...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    // Simulate payment process and navigate to PaymentCard
    Future.delayed(Duration(seconds: 2), () async {
      Navigator.of(context).pop();

      await _addTransactionToFirestore(totalPrice);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCard(
            totalPrice: totalPrice.toDouble(),
          ),
        ),
      );
    });
  }

  Future<void> _addTransactionToFirestore(int amount) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final transactionDoc = firestore.collection('transactions').doc();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await transactionDoc.set({
        'amount': amount.toDouble(),
        'type': 'addition',
        'date': Timestamp.now(),
        'description': 'Funds added via Add Funds Page',
        'userId': uid,
      });
    } catch (e) {
      print('Error adding transaction to Firestore: $e');
    }
  }
}

