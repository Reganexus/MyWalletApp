import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/utils/color_utils.dart';
import 'package:mywallet/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class AddAccountForm extends StatefulWidget {
  final Account? existingAccount;

  const AddAccountForm({super.key, this.existingAccount});

  @override
  State<AddAccountForm> createState() => _AddAccountFormState();
}

Future<void> showAddAccountModal({
  required BuildContext context,
  Account? existingAccount,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (BuildContext modalContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 20,
                ),
                child: AddAccountForm(existingAccount: existingAccount),
              ),
            ),
          );
        },
      );
    },
  );
}

class _AddAccountFormState extends State<AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedCurrency = "PHP";
  AccountCategory _selectedCategory = AccountCategory.other;
  Color _selectedColor = ColorUtils.availableColors.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAccount != null) {
      _nameController.text = widget.existingAccount!.name;
      _balanceController.text = widget.existingAccount!.balance.toString();
      _selectedCurrency = widget.existingAccount!.currency;
      _selectedCategory = widget.existingAccount!.category;
      _selectedColor = widget.existingAccount!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _addAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    final hex = ColorUtils.colorToHex(_selectedColor);

    final newAccount = (widget.existingAccount ??
            Account(
              category: _selectedCategory,
              name: name,
              currency: _selectedCurrency,
              balance: balance,
            ))
        .copyWith(
          name: name,
          category: _selectedCategory,
          currency: _selectedCurrency,
          balance: balance,
          colorHex: hex,
        );

    final accountsProvider = context.read<AccountProvider>();

    if (widget.existingAccount != null) {
      // **Show confirmation dialog before updating**
      final confirm = await showConfirmationDialog(
        context: context,
        title: "Update Account",
        content:
            "Do you want to save changes to ${widget.existingAccount!.name}?",
        confirmText: "Update",
        confirmColor: Colors.blue,
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      await accountsProvider.updateAccount(newAccount);
    } else {
      await accountsProvider.addAccount(newAccount);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingAccount != null ? "Update Account" : "Add Account",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 1. Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Account Name",
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? 'Please enter a name'
                          : null,
            ),
            const SizedBox(height: 12),

            // 2. Currency
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: "Currency",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "PHP",
                  child: Text("PHP - Philippine Peso"),
                ),
                DropdownMenuItem(value: "USD", child: Text("USD - US Dollar")),
                DropdownMenuItem(value: "EUR", child: Text("EUR - Euro")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
            const SizedBox(height: 12),

            // 3. Initial Value
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Initial Value",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 4. Category
            DropdownButtonFormField<AccountCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items:
                  AccountCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(categoryIcons[category], size: 20),
                          const SizedBox(width: 8),
                          Text(categoryLabels[category] ?? category.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 12),

            // 5. Color Selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  ColorUtils.availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 20,
                        child:
                            _selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _addAccount,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : Text(
                        widget.existingAccount != null
                            ? "Update Account"
                            : "Add Account",
                      ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
