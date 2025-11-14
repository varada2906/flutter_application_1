import 'package:flutter/material.dart';

class PassengerFlowPredictionScreen extends StatefulWidget {
  @override
  State<PassengerFlowPredictionScreen> createState() =>
      _PassengerFlowPredictionScreenState();
}

class _PassengerFlowPredictionScreenState
    extends State<PassengerFlowPredictionScreen> {
  String fromLocation = 'Hinjawadi';
  String toLocation = 'Swargate';

  String busLine = 'Bjadso';
  String busNo = 'Swargate';

  String savedDaysAgo = '5 days ago';

  String flowLevel = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passenger Flow Prediction'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Passenger Flow Prediction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('$fromLocation to $toLocation'),
            ),
            ListTile(
              leading: Icon(Icons.directions_bus),
              title: Text('Bus line: $busLine'),
              subtitle: Text('Bus no: $busNo'),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Saved $savedDaysAgo'),
            ),
            SizedBox(height: 20),
            Text('Flow Level:', style: TextStyle(fontSize: 18)),
            ListTile(
              leading: Icon(Icons.circle, color: Colors.orange),
              title: Text(flowLevel),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Reate clicked')));
              },
              child: Text('Reate'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Offline'),
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