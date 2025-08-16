import 'package:flutter/material.dart';

class AddTransactionButton extends StatelessWidget {
  const AddTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add Transaction Button Pressed")),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
