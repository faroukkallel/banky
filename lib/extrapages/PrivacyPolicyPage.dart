import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to our Privacy Policy page. Here, you will find detailed information on how we handle your personal data and privacy. We are committed to protecting your privacy and ensuring that your data is safe with us.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey[600],
                ),
              ),
              SizedBox(height: 24),
              Text(
                '1. Information We Collect',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We collect various types of information to provide and improve our services. This includes personal information you provide directly and usage data collected automatically.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                '2. How We Use Your Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your information is used to personalize your experience, provide customer support, and improve our services. We may also use your data for research and marketing purposes, with your consent.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey[600],
                ),
              ),
              // Add more sections as needed
            ],
          ),
        ),
      ),
    );
  }
}
