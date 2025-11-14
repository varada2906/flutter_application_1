import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/alert_item.dart';


class PredictiveAlertsScreen extends StatefulWidget {
  @override
  State<PredictiveAlertsScreen> createState() => _PredictiveAlertsScreenState();
}

class _PredictiveAlertsScreenState extends State<PredictiveAlertsScreen> {
  List<AlertItem> alerts = [
    AlertItem(
      time: '3:02 AM',
      busNo: '361',
      stop: 'Sule gate',
      arrival: '-2:25 AM',
    ),
    AlertItem(
      time: '3:02 AM',
      busNo: '361',
      stop: 'Sule gate',
      arrival: '-5:05 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Suggestions'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('From Sangrute', style: TextStyle(fontSize: 18)),
            Text('To Mauprad Phase 2', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Today 3:02 AM', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('${alert.busNo} - ${alert.stop}'),
                    subtitle: Text('Arrival: ${alert.arrival}'),
                    trailing: Text(alert.time),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/paymentSuccess');
              },
              child: Text('Foods'),
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