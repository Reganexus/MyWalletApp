import 'package:flutter/material.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
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
  double? _remainingNeeded;

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _goalFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _accountFocus.addListener(() => setState(() {}));
    _goalFocus.addListener(() => setState(() {}));
    _amountFocus.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _accountFocus.dispose();
    _goalFocus.dispose();
    _amountFocus.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canContribute {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedGoalId == null || _selectedAccountId == null) return false;

    final goals = context.read<GoalProvider>().goals;
    final accounts = context.read<AccountProvider>().accounts;

    final goal = goals.firstWhere((g) => g.id == _selectedGoalId);
    final account = accounts.firstWhere((a) => a.id == _selectedAccountId);

    final remainingNeeded = goal.targetAmount - goal.savedAmount;

    if (amount <= 0) return false;
    if (amount > remainingNeeded) return false;
    if (amount > account.balance) return false;

    return true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final goalProvider = context.read<GoalProvider>();
    final accountProvider = context.read<AccountProvider>();

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final account = accountProvider.accounts.firstWhere(
        (acc) => acc.id == _selectedAccountId,
      );
      final goal = context.read<GoalProvider>().goals.firstWhere(
        (g) => g.id == _selectedGoalId,
      );

      // ✅ Validation: contribution should not exceed remaining needed
      final remainingNeeded = goal.targetAmount - goal.savedAmount;
      if (amount > remainingNeeded) {
        if (!mounted) return;
        OverlayMessage.show(
          context,
          message:
              "Contribution exceeds remaining needed (${remainingNeeded.toStringAsFixed(2)})",
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      // ✅ Validation: account balance must be >= contribution
      if (amount > account.balance) {
        if (!mounted) return;
        OverlayMessage.show(
          context,
          message:
              "Insufficient balance. Your account only has ${account.balance.toStringAsFixed(2)}",
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      // ✅ Update goal
      await goalProvider.contributeToGoal(_selectedGoalId!, amount);

      // ✅ Record transaction (handles account deduction)
      if (!mounted) return;
      final txProvider = context.read<TransactionProvider>();
      await txProvider.addTransaction(
        TransactionModel(
          accountId: _selectedAccountId!,
          amount: amount,
          type: "expense",
          category: "Goal Contribution",
          note: "Contributed to goal ID $_selectedGoalId",
          date: DateTime.now(),
        ),
      );

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
                  if (val != null) {
                    final goal = goals.firstWhere((g) => g.id == val);
                    _remainingNeeded = goal.targetAmount - goal.savedAmount;
                  } else {
                    _remainingNeeded = null;
                  }
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

            // ✅ Remaining Needed (read-only)
            if (_remainingNeeded != null)
              Column(
                children: [
                  TextFormField(
                    enabled: false,
                    initialValue: _remainingNeeded!.toStringAsFixed(2),
                    decoration: buildInputDecoration(
                      "Remaining Needed",
                      color: baseColor,
                      isFocused: false,
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

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
              validator: (val) {
                if (val == null || val.isEmpty) return "Enter amount";
                final entered = double.tryParse(val) ?? 0;
                if (_remainingNeeded != null && entered > _remainingNeeded!) {
                  return "Amount exceeds remaining needed ($_remainingNeeded)";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_isLoading || !_canContribute) ? null : _submit,
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
