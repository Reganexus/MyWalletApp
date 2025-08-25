// widgets/Transactions/add_transaction_modal.dart
import 'package:flutter/material.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:provider/provider.dart';

class AddTransactionForm extends StatelessWidget {
  final int initialTabIndex;

  const AddTransactionForm({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 2,
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: "Add Record"), Tab(text: "Pay Bill")],
            ),
            const Expanded(
              child: TabBarView(children: [_AddRecordForm(), _PayBillForm()]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecordForm extends StatefulWidget {
  const _AddRecordForm();

  @override
  State<_AddRecordForm> createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<_AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAccountId;
  String _type = "expense";
  String _category = "";
  double _amount = 0;
  String? _note;

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
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
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
              decoration: const InputDecoration(labelText: "Select Account"),
              validator:
                  (val) => val == null ? "Please select an account" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: "income", child: Text("Income")),
                DropdownMenuItem(value: "expense", child: Text("Expense")),
              ],
              onChanged: (val) => setState(() => _type = val!),
              decoration: const InputDecoration(labelText: "Transaction Type"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _amount > 0 ? _amount.toString() : null,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
              validator:
                  (val) => val == null || val.isEmpty ? "Enter amount" : null,
              onSaved: (val) => _amount = double.parse(val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category.isNotEmpty ? _category : null,
              items:
                  (_type == "income" ? incomeCategories : expenseCategories)
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _category = val ?? ""),
              decoration: const InputDecoration(labelText: "Category"),
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? "Please select a category"
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _note,
              decoration: const InputDecoration(labelText: "Note (optional)"),
              onSaved: (val) => _note = val,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                _formKey.currentState?.save();

                final tx = TransactionModel(
                  accountId: _selectedAccountId!,
                  type: _type,
                  category: _category,
                  amount: _amount,
                  date: DateTime.now(),
                  note: _note,
                );

                final txProvider = context.read<TransactionProvider>();
                await txProvider.addTransaction(tx);

                if (!context.mounted) return;
                await ProviderReloader.reloadAll(context);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayBillForm extends StatefulWidget {
  const _PayBillForm();

  @override
  State<_PayBillForm> createState() => _PayBillFormState();
}

class _PayBillFormState extends State<_PayBillForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAccountId;
  Bill? _selectedBill;
  double? _convertedAmount;
  bool _loadingConversion = false;

  Future<void> _convertAmount(int accountId, Bill bill) async {
    final accounts = context.read<AccountProvider>().accounts;
    final account = accounts.firstWhere(
      (acc) => acc.id == accountId,
      orElse: () => accounts.first,
    );

    setState(() => _loadingConversion = true);

    double amount = bill.amount;

    if (account.currency != bill.currency) {
      final rate = await ForexService.getRate(bill.currency, account.currency);
      if (rate != null) {
        amount = bill.amount * rate;
      }
    }

    setState(() {
      _convertedAmount = amount;
      _loadingConversion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final bills = context.watch<BillProvider>().bills;
    final unpaidBills =
        bills.where((b) => b.status == BillStatus.pending).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
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
              onChanged: (val) async {
                setState(() => _selectedAccountId = val);
                if (_selectedBill != null && val != null) {
                  await _convertAmount(val, _selectedBill!);
                }
              },
              decoration: const InputDecoration(labelText: "Select Account"),
              validator:
                  (val) => val == null ? "Please select an account" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Bill>(
              initialValue: _selectedBill,
              items:
                  unpaidBills
                      .map(
                        (bill) => DropdownMenuItem(
                          value: bill,
                          child: Text(
                            "${bill.name} - ₱${bill.amount.toStringAsFixed(2)}",
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) async {
                setState(() => _selectedBill = val);
                if (_selectedAccountId != null && val != null) {
                  await _convertAmount(_selectedAccountId!, val);
                }
              },
              decoration: const InputDecoration(
                labelText: "Select Bill to Pay",
              ),
              validator: (val) => val == null ? "Please select a bill" : null,
            ),
            if (_loadingConversion) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (_convertedAmount != null) ...[
              const SizedBox(height: 12),
              Text(
                "Will be deducted: ${_convertedAmount!.toStringAsFixed(2)} ${accounts.firstWhere((a) => a.id == _selectedAccountId).currency}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;

                final bill = _selectedBill!;
                final accountId = _selectedAccountId!;

                // Use the converted amount (already in account currency) or the bill amount
                double finalAmount = _convertedAmount ?? bill.amount;

                // Create transaction
                final tx = TransactionModel(
                  accountId: accountId,
                  type: "expense",
                  category: bill.name,
                  amount: finalAmount,
                  date: DateTime.now(),
                  note: "Paid ${bill.name}",
                );

                final billProvider = context.read<BillProvider>();
                final txProvider = context.read<TransactionProvider>();

                await billProvider.markBillPaid(bill.id!);
                await txProvider.addTransaction(tx);

                if (!context.mounted) return;
                await ProviderReloader.reloadAll(context);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Pay Bill"),
            ),
          ],
        ),
      ),
    );
  }
}
