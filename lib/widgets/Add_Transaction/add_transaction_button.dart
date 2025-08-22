// widgets/Transactions/add_transaction_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAccountId;
  String _type = "expense";
  String _category = "";
  double _amount = 0;
  String? _note;

  // Predefined categories
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown for accounts
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
            validator: (val) => val == null ? "Please select an account" : null,
          ),

          const SizedBox(height: 12),

          // Transaction Type
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

          // Amount
          TextFormField(
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
            validator:
                (val) => val == null || val.isEmpty ? "Enter amount" : null,
            onSaved: (val) => _amount = double.parse(val!),
          ),

          const SizedBox(height: 12),

          // Category
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

          // Note
          TextFormField(
            decoration: const InputDecoration(labelText: "Note (optional)"),
            onSaved: (val) => _note = val,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();

                final tx = TransactionModel(
                  accountId: _selectedAccountId!,
                  type: _type,
                  category: _category,
                  amount: _amount,
                  date: DateTime.now(),
                  note: _note,
                );

                await context.read<TransactionProvider>().addTransaction(tx);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save Transaction"),
          ),
        ],
      ),
    );
  }
}
