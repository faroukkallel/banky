import 'package:banky/scan_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreditCardManagerPage extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Credit Cards',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No cards available.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var cards = userData['creditCardSaved'] as List<dynamic>? ?? [];

          if (cards.isEmpty) {
            return Center(child: Text('No cards available.'));
          }

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              var card = cards[index] as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.credit_card, color: Colors.teal),
                title: Text(card['cardNumber'] ?? '**** **** **** 0000'),
                subtitle: Text(card['cardHolder'] ?? 'Card Holder'),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.teal),
                  onPressed: () {
                    _editCard(context, card, index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => ScanPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to edit an existing card
  void _editCard(BuildContext context, Map<String, dynamic> card, int index) {
    TextEditingController cardNumberController = TextEditingController(text: card['cardNumber']);
    TextEditingController cardHolderController = TextEditingController(text: card['cardHolder']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            TextField(
              controller: cardHolderController,
              decoration: InputDecoration(labelText: 'Card Holder'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (cardNumberController.text.isNotEmpty && cardHolderController.text.isNotEmpty) {
                _firestore.collection('users').doc(uid).update({
                  'creditCardSaved': FieldValue.arrayRemove([card])
                }).then((_) {
                  _firestore.collection('users').doc(uid).update({
                    'creditCardSaved': FieldValue.arrayUnion([
                      {
                        'cardNumber': cardNumberController.text,
                        'cardHolder': cardHolderController.text,
                      }
                    ])
                  });
                });

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
