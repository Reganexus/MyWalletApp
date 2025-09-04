import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/profile_provider.dart';

class EmptyTransactionsState extends StatelessWidget {
  final VoidCallback onAdd;
  const EmptyTransactionsState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: baseColor,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            "No transactions yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            "Once you record your transactions, they will appear here. Start by adding a new transaction.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Add button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Transaction",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: baseColor,
                shadowColor: baseColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
