import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../PaymentCard.dart';

class AddFundsPage extends StatefulWidget {
  @override
  _AddFundsPageState createState() => _AddFundsPageState();
}

class _AddFundsPageState extends State<AddFundsPage> {
  int? totalPrice; // Variable to store the selected amount

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Funds'),
        backgroundColor: CupertinoColors.white,
        border: Border(bottom: BorderSide(color: CupertinoColors.lightBackgroundGray)),
      ),
      child: SafeArea(
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

              _buildSectionHeader(context, 'Payment Method'),
              SizedBox(height: 10),
              _buildCreditCardOption(),

              SizedBox(height: 30),

              _buildSectionHeader(context, 'Receive Funds via QR Code'),
              SizedBox(height: 10),
              _buildQRCodeOption(),

              SizedBox(height: 30),

              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  color: CupertinoColors.activeGreen,
                  borderRadius: BorderRadius.circular(30),
                  child: Text('Add Funds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (totalPrice != null && totalPrice! > 0) {
                      _showProcessingDialog(context, totalPrice!);
                    } else {
                      // Show an alert or error if no amount is selected
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text('Error'),
                          content: Text('Please select or enter an amount to add.'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.black,
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
        });
      },
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: totalPrice == value ? CupertinoColors.systemGreen : CupertinoColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CupertinoColors.systemGrey, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(amount, style: TextStyle(fontSize: 16, color: CupertinoColors.black)),
        ),
      ),
    );
  }

  Widget _buildCustomAmountField() {
    return CupertinoTextField(
      placeholder: 'Enter custom amount',
      prefix: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(CupertinoIcons.money_dollar, color: CupertinoColors.systemGrey),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      keyboardType: TextInputType.number,
      decoration: BoxDecoration(
        color: CupertinoColors.extraLightBackgroundGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CupertinoColors.systemGrey.withOpacity(0.5)),
      ),
      style: TextStyle(fontSize: 16),
      onChanged: (value) {
        setState(() {
          totalPrice = int.tryParse(value); // Update the custom amount
        });
      },
    );
  }

  Widget _buildCreditCardOption() {
    return GestureDetector(
      onTap: () {
        // Handle credit card selection
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CupertinoColors.systemGrey, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.creditcard, color: CupertinoColors.systemBlue, size: 24),
            SizedBox(width: 10),
            Text('Credit Card', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeOption() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey, width: 0.5),
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
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProcessingDialog(BuildContext context, int totalPrice) {
    // Create a variable to hold the dialog's context
    late BuildContext dialogContext;

    // Show the processing dialog
    showCupertinoDialog(
      context: context,
      builder: (context) {
        dialogContext = context; // Save the context for later dismissal
        return CupertinoAlertDialog(
          title: Text('Processing...'),
          content: Column(
            children: [
              SizedBox(height: 16),
              CupertinoActivityIndicator(radius: 12),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    ).then((_) {
      // When the dialog is dismissed, you can perform additional actions if needed
      // For example, handle any clean-up or state updates
    });

    // Simulate payment process and navigate to PaymentCard
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(dialogContext).pop(); // Dismiss the dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCard(
            totalPrice: totalPrice.toDouble(), // Pass the selected amount to the PaymentCard
          ),
        ),
      );
    });
  }
}
