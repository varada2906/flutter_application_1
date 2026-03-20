import 'package:flutter/material.dart';

class FeedbackDetailScreen extends StatefulWidget {
  final String? initialFeedback; // Made optional
  
  const FeedbackDetailScreen({Key? key, this.initialFeedback}) : super(key: key); // Made optional

  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  String selectedPurvo = 'Plus';
  String selectedRating = 'Telly Good';
  String experienceText = '';

  final purvoOptions = ['Plus', 'Telly Good', 'Detail', 'Average', 'Foter'];

  @override
  void initState() {
    super.initState();
    // Set initial feedback if provided
    if (widget.initialFeedback != null) {
      experienceText = widget.initialFeedback!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Detail'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the initial feedback if available
              if (widget.initialFeedback != null && widget.initialFeedback!.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Feedback:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(widget.initialFeedback!),
                    ],
                  ),
                ),
              if (widget.initialFeedback != null && widget.initialFeedback!.isNotEmpty) 
                SizedBox(height: 20),
              
              Text(
                'Additional Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              
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
                decoration: InputDecoration(
                  labelText: 'Purvo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Describe your experience',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  experienceText = val;
                },
              ),
              SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Detailed feedback submitted'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.popUntil(context, (route) {
                      return route.settings.name == '/welcome' || route.isFirst;
                    });
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}