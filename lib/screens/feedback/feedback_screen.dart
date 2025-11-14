import 'package:flutter/material.dart';

class FeedbackDetailScreen extends StatefulWidget {
  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  String selectedPurvo = 'Plus';
  String selectedRating = 'Telly Good';
  String experienceText = '';

  final purvoOptions = ['Plus', 'Telly Good', 'Detail', 'Average', 'Foter'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Detail'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedPurvo,
              items: purvoOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedPurvo = val;
                  });
                }
              },
              decoration: InputDecoration(labelText: 'Purvo'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRating,
              items: ['Telly Good', 'Detail', 'Average', 'Foter']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedRating = val;
                  });
                }
              },
              decoration: InputDecoration(labelText: 'Rating'),
            ),
            SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Describe your experience',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                experienceText = val;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detailed feedback submitted')),
                );
                Navigator.popUntil(context, ModalRoute.withName('/welcome'));
              },
              child: Text('Submit'),
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