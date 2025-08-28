import 'package:flutter/material.dart';

class EmptyBillsState extends StatelessWidget {
  final VoidCallback onAdd;
  const EmptyBillsState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          const Text(
            "No upcoming bills",
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text("Add Bill"),
          ),
        ],
      ),
    );
  }
}
