import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ConversionResult extends StatelessWidget {
  final String from;
  final String to;
  final double? rate;

  const ConversionResult({
    super.key,
    required this.from,
    required this.to,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    if (rate == null) return const SizedBox.shrink();

    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.9),
            baseColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Conversion Rate",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            Text(
              '$from → $to: ${rate!.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
