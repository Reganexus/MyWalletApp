import 'package:flutter/material.dart';

class EmptyAccountsState extends StatelessWidget {
  final VoidCallback onAdd;
  const EmptyAccountsState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              "No accounts yet",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Add Account"),
            ),
          ],
        ),
      ),
    );
  }
}
