import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class BillDisclaimer extends StatelessWidget {
  const BillDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    final theme = Theme.of(context);

    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : theme.colorScheme.primary;

    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: baseColor, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Note: Adding a bill here only applies to monthly bills. "
                "Other recurrence options (daily, weekly, yearly) are not yet supported.",
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
