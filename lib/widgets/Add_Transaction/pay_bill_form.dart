import 'package:flutter/material.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';

class AddBillForm extends StatefulWidget {
  const AddBillForm({super.key});

  @override
  State<AddBillForm> createState() => _AddBillFormState();
}

class _AddBillFormState extends State<AddBillForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAccountId;
  Bill? _selectedBill;
  bool _isLoading = false;

  final _billNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final _accountFocus = FocusNode();
  final _billFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _billNameController.text = "Bill Name";
    _billFocus.addListener(() => setState(() {}));
    _accountFocus.addListener(() => setState(() {}));
    _amountFocus.addListener(() => setState(() {}));
    _noteFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _billNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _accountFocus.dispose();
    _billFocus.dispose();
    _amountFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBill == null) {
      OverlayMessage.show(
        context,
        message: "Please select a bill to pay.",
        isError: true,
      );
      return;
    }

    final billId = _selectedBill!.id;
    if (billId == null) {
      OverlayMessage.show(
        context,
        message: "Error: The selected bill has no ID.",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final tx = TransactionModel(
      accountId: _selectedAccountId!,
      type: "expense",
      category: _selectedBill!.name,
      amount: _selectedBill!.amount,
      date: DateTime.now(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    final txProvider = context.read<TransactionProvider>();
    final billProvider = context.read<BillProvider>();

    try {
      await txProvider.addTransaction(tx);
      await billProvider.payBill(billId);

      if (!mounted) return;
      await ProviderReloader.reloadAll(context);

      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${_selectedBill!.name} paid successfully!",
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      OverlayMessage.show(
        context,
        message: "Failed to process payment: $e",
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final pendingBills =
        context
            .watch<BillProvider>()
            .bills
            .where((b) => b.status == BillStatus.pending)
            .toList();
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    final filteredAccounts =
        _selectedBill == null
            ? accounts
            : accounts
                .where((acc) => acc.currency == _selectedBill!.currency)
                .toList();

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Name Dropdown
            DropdownButtonFormField<int>(
              focusNode: _billFocus,
              isExpanded: true,
              initialValue: _selectedBill?.id, // use ID here
              items:
                  pendingBills.map((bill) {
                    return DropdownMenuItem(
                      value: bill.id,
                      child: Text(
                        "${bill.name} (${bill.currency} ${bill.amount})",
                      ),
                    );
                  }).toList(),
              onChanged: (id) {
                setState(() {
                  _selectedBill = pendingBills.firstWhere((b) => b.id == id);
                  if (_selectedBill != null) {
                    _amountController.text = _selectedBill!.amount.toString();
                    _selectedAccountId = null; // reset account selection
                  }
                });
              },
              decoration: buildInputDecoration(
                "Select Bill",
                color: baseColor,
                isFocused: _billFocus.hasFocus,
                context: context,
              ),
              validator: (val) => val == null ? "Please select a bill" : null,
            ),
            const SizedBox(height: 12),

            // Select Account Dropdown
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

            // Amount Text Field (auto-populated and disabled)
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocus,
              enabled: false,
              decoration: buildInputDecoration(
                "Amount",
                color: baseColor,
                isFocused: _amountFocus.hasFocus,
                context: context,
              ),
              keyboardType: TextInputType.number,
              validator:
                  (val) =>
                      val == null || val.isEmpty ? "Amount is required" : null,
            ),
            const SizedBox(height: 12),

            // Note Text Field
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

            // Save Button
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
                          "Pay Bill",
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
