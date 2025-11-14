import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const InfoCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: Text(trailing, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}