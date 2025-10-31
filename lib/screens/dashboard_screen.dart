import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Item 1',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 200),
                Text(
                  'Item 2',
                  style: TextStyle(fontSize: 16),
                ),

                Text(
                  'Item 1',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 200),
                Text(
                  'Item 2',
                  style: TextStyle(fontSize: 16),
                ),

                    Text(
                  'Item 1',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 200),
                Text(
                  'Item 2',
                  style: TextStyle(fontSize: 16),
                ),
                // Add more dashboard widgets here
              ],
            ),
          ),
        ),
      )
    );
  }
}