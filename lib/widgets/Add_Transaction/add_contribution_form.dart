import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:provider/provider.dart';

class AddContribution extends StatefulWidget {
  const AddContribution({super.key});

  @override
  State<AddContribution> createState() => _AddContributionState();
}

class _AddContributionState extends State<AddContribution> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAccountId;
  int? _selectedGoalId;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _goalFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _accountFocus.addListener(() => setState(() {}));
    _goalFocus.addListener(() => setState(() {}));
    _amountFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _accountFocus.dispose();
    _goalFocus.dispose();
    _amountFocus.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final accountProvider = context.read<AccountProvider>();
    final goalProvider = context.read<GoalProvider>();

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;

      // Deduct from account
      await accountProvider.deductFromAccount(_selectedAccountId!, amount);

      // Update goal
      await goalProvider.contributeToGoal(_selectedGoalId!, amount);

      if (!mounted) return;

      OverlayMessage.show(context, message: "Contribution successful!");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "Failed to contribute: $e",
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    final accounts = context.watch<AccountProvider>().accounts;
    final goals = context.watch<GoalProvider>().goals;

    // ✅ filter accounts based on selected goal
    final filteredAccounts =
        _selectedGoalId == null
            ? accounts
            : accounts.where((acc) {
              final goal = goals.firstWhere(
                (g) => g.id == _selectedGoalId,
                orElse: () => goals.first,
              );
              return acc.currency == goal.currency;
            }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 8,
        right: 8,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Select Goal first
            DropdownButtonFormField<int>(
              focusNode: _goalFocus,
              isExpanded: true,
              initialValue: _selectedGoalId,
              items:
                  goals.map((goal) {
                    return DropdownMenuItem(
                      value: goal.id,
                      child: Text(
                        "${goal.name} (Target: ${goal.currency} ${goal.targetAmount})",
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedGoalId = val;
                  _selectedAccountId = null; // reset when goal changes
                });
              },
              decoration: buildInputDecoration(
                "Select Goal",
                color: baseColor,
                isFocused: _goalFocus.hasFocus,
                context: context,
              ),
              validator: (val) => val == null ? "Please select a goal" : null,
            ),
            const SizedBox(height: 12),

            // Now filter accounts by goal currency
            DropdownButtonFormField<int>(
              focusNode: _accountFocus,
              isExpanded: true,
              initialValue: _selectedAccountId,
              items:
                  filteredAccounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text(
                        "${acc.name} (${acc.currency} ${acc.balance})",
                      ),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
              decoration: buildInputDecoration(
                "Select Account",
                color: baseColor,
                isFocused: _accountFocus.hasFocus,
                context: context,
              ),
              validator:
                  (val) => val == null ? "Please select an account" : null,
            ),
            const SizedBox(height: 12),

            // Amount
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocus,
              decoration: buildInputDecoration(
                "Contribution Amount",
                color: baseColor,
                isFocused: _amountFocus.hasFocus,
                context: context,
              ),
              keyboardType: TextInputType.number,
              validator:
                  (val) => val == null || val.isEmpty ? "Enter amount" : null,
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: baseColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Contribute",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
