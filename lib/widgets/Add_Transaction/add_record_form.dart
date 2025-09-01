import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';

class AddRecordForm extends StatefulWidget {
  const AddRecordForm({super.key});

  @override
  State<AddRecordForm> createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAccountId;
  String _type = "expense";
  String _category = "";
  bool _isLoading = false;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Track focus states
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _typeFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();

  final List<String> expenseCategories = [
    "Food",
    "Transportation",
    "Utilities",
    "Entertainment",
    "Shopping",
    "Health",
    "Education",
    "Others",
  ];
  final List<String> incomeCategories = [
    "Salary",
    "Freelance",
    "Investments",
    "Gifts",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    _amountFocus.addListener(() => setState(() {}));
    _noteFocus.addListener(() => setState(() {}));
    _accountFocus.addListener(() => setState(() {}));
    _typeFocus.addListener(() => setState(() {}));
    _categoryFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    _noteFocus.dispose();
    _accountFocus.dispose();
    _typeFocus.dispose();
    _categoryFocus.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tx = TransactionModel(
      accountId: _selectedAccountId!,
      type: _type,
      category: _category,
      amount: double.tryParse(_amountController.text) ?? 0,
      date: DateTime.now(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    final txProvider = context.read<TransactionProvider>();
    await txProvider.addTransaction(tx);

    if (!mounted) return;
    await ProviderReloader.reloadAll(context);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

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
            // Account dropdown
            DropdownButtonFormField<int>(
              focusNode: _accountFocus,
              initialValue: _selectedAccountId,
              items:
                  accounts
                      .map(
                        (acc) => DropdownMenuItem(
                          value: acc.id,
                          child: Text(
                            "${acc.name} (${acc.currency} ${acc.balance})",
                          ),
                        ),
                      )
                      .toList(),
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

            // Transaction type dropdown
            DropdownButtonFormField<String>(
              focusNode: _typeFocus,
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: "income", child: Text("Income")),
                DropdownMenuItem(value: "expense", child: Text("Expense")),
              ],
              onChanged:
                  (val) => setState(() {
                    _type = val!;
                    _category = "";
                  }),
              decoration: buildInputDecoration(
                "Transaction Type",
                color: baseColor,
                isFocused: _typeFocus.hasFocus,
                context: context,
              ),
            ),
            const SizedBox(height: 12),

            // Amount input
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocus,
              decoration: buildInputDecoration(
                "Amount",
                color: baseColor,
                isFocused: _amountFocus.hasFocus,
                context: context,
              ),
              keyboardType: TextInputType.number,
              validator:
                  (val) => val == null || val.isEmpty ? "Enter amount" : null,
            ),
            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<String>(
              focusNode: _categoryFocus,
              initialValue: _category.isNotEmpty ? _category : null,
              items:
                  (_type == "income" ? incomeCategories : expenseCategories)
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _category = val ?? ""),
              decoration: buildInputDecoration(
                "Category",
                color: baseColor,
                isFocused: _categoryFocus.hasFocus,
                context: context,
              ),
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? "Please select a category"
                          : null,
            ),
            const SizedBox(height: 12),

            // Note input
            TextFormField(
              controller: _noteController,
              focusNode: _noteFocus,
              decoration: buildInputDecoration(
                "Note (optional)",
                color: baseColor,
                isFocused: _noteFocus.hasFocus,
                context: context,
              ),
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
                        ? CircularProgressIndicator(color: baseColor)
                        : const Text(
                          "Save Transaction",
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
