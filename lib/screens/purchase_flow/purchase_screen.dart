import 'package:flutter/material.dart';
import 'pass_card.dart';

class PurchaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Pune Commute'), leading: BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility Mode Enabled',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            PassCard(
              title: 'In 300 meters',
              subtitle: 'Text-Speech Out',
              price: '₹45',
            ),
            SizedBox(height: 12),
            PassCard(title: 'Day Pass', subtitle: 'Tax', price: '₹90'),
            SizedBox(height: 12),
            PassCard(title: 'Monthly Pass', subtitle: 'Toll', price: '₹1,200'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/instruction');
              },
              child: Text('Purchase'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}