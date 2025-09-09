import 'package:flutter/material.dart';
import 'package:mywallet/widgets/Add_Transaction/add_contribution_form.dart';
import 'package:mywallet/widgets/Add_Transaction/pay_bill_form.dart';
import 'package:mywallet/widgets/Add_Transaction/add_record_form.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/profile_provider.dart';

class AccountBillsSwitcher extends StatefulWidget {
  final String initialSection;

  const AccountBillsSwitcher({super.key, required this.initialSection});

  @override
  State<AccountBillsSwitcher> createState() => _AccountBillsSwitcherState();
}

class _AccountBillsSwitcherState extends State<AccountBillsSwitcher> {
  late String selectedSection;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.initialSection;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Pill Buttons ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPillButton("Add Record", "records", baseColor),
              _buildPillButton("Pay Bills", "bills", baseColor),
              _buildPillButton("Contribute", "contribute", baseColor),
            ],
          ),
        ),

        // --- Content Switcher ---
        if (selectedSection == "records") const AddRecordForm(),
        if (selectedSection == "bills") const AddBillForm(),
        if (selectedSection == "contribute") const AddContribution(),
      ],
    );
  }

  Widget _buildPillButton(String label, String value, Color baseColor) {
    final bool isSelected = selectedSection == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSection = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? baseColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? baseColor
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
