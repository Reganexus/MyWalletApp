import 'package:flutter/material.dart';

class UpcomingBillsWidget extends StatelessWidget {
  const UpcomingBillsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("Upcoming Bills Component Imported")),
      ),
    );
  }
}
