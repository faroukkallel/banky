import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
        backgroundColor: Colors.blueGrey[900], // Change to your app's theme color
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildFAQItem(
              context,
              'How do I reset my password?',
              'To reset your password, go to Settings > Account > Reset Password. Follow the prompts to create a new password.',
            ),
            _buildFAQItem(
              context,
              'How do I contact support?',
              'You can contact support by emailing support@example.com or through the in-app chat. Our support team is available 24/7.',
            ),
            _buildFAQItem(
              context,
              'How can I apply for a new credit card?',
              'To apply for a new credit card, go to the Credit Cards section in the app and select "Apply Now." Follow the instructions to complete your application.',
            ),
            _buildFAQItem(
              context,
              'How do I report a lost or stolen card?',
              'If your card is lost or stolen, go to the Cards section in the app and select "Report Lost/Stolen Card." You can also call our support hotline immediately to report it.',
            ),
            _buildFAQItem(
              context,
              'How can I view my transaction history?',
              'To view your transaction history, go to the Accounts section and select the account you wish to view. You will find a list of recent transactions there.',
            ),
            _buildFAQItem(
              context,
              'How do I set up automatic payments?',
              'To set up automatic payments, go to the Payments section and select "Set Up Auto-Pay." Choose your payment preferences and confirm your settings.',
            ),
            _buildFAQItem(
              context,
              'What should I do if I see an unauthorized transaction?',
              'If you see an unauthorized transaction, go to the Transactions section, select the transaction, and choose "Report Issue." Contact support if necessary.',
            ),
            // Add more FAQ items as needed
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blueGrey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
