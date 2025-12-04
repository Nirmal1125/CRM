import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRM Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(title: Text('Total Customers: 0')),
            ), // Placeholder
            Card(child: ListTile(title: Text('Total Leads: 0'))),
            // Add more placeholders for tasks, charts later
          ],
        ),
      ),
    );
  }
}
