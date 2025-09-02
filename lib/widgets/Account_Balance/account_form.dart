// lib/widgets/add_account_form.dart
import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/WidgetHelper/color_picker.dart';
import 'package:mywallet/utils/Design/color_utils.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:provider/provider.dart';

class AccountForm extends StatefulWidget {
  final Account? existingAccount;

  const AccountForm({super.key, this.existingAccount});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  // focus tracking
  final _nameFocusNode = FocusNode();
  final _balanceFocusNode = FocusNode();
  final _currencyFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  String? _focusedField;

  String _selectedCurrency = "PHP";
  AccountCategory _selectedCategory = AccountCategory.other;
  Color _selectedColor = ColorUtils.availableColors.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // attach listeners
    void attachListener(FocusNode node, String field) {
      node.addListener(() {
        if (node.hasFocus) {
          setState(() => _focusedField = field);
        } else if (_focusedField == field) {
          setState(() => _focusedField = null);
        }
      });
    }

    attachListener(_nameFocusNode, "name");
    attachListener(_balanceFocusNode, "balance");
    attachListener(_currencyFocusNode, "currency");
    attachListener(_categoryFocusNode, "category");

    // prefill for editing
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
    _nameFocusNode.dispose();
    _balanceFocusNode.dispose();
    _currencyFocusNode.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addAccount() async {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;
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
      final confirm = await showConfirmationDialog(
        context: context,
        title: "Update Account",
        content:
            "Do you want to save changes to ${widget.existingAccount!.name}?",
        confirmText: "Update",
        confirmColor: baseColor,
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      await accountsProvider.updateAccount(newAccount);
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${newAccount.name} updated successfully!",
      );
    } else {
      await accountsProvider.addAccount(newAccount);
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${newAccount.name} added successfully!",
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + 16,
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
            Center(
              child: Text(
                widget.existingAccount != null
                    ? "Update Account"
                    : "Add Account",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 1. Name
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: buildInputDecoration(
                "Account Name",
                prefixIcon: const Icon(Icons.account_balance_wallet),
                color: baseColor,
                isFocused: _focusedField == "name",
                context: context,
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
              initialValue: _selectedCurrency,
              focusNode: _currencyFocusNode,
              decoration: buildInputDecoration(
                "Currency",
                prefixIcon: const Icon(Icons.currency_exchange),
                color: baseColor,
                isFocused: _focusedField == "currency",
                context: context,
              ),
              items:
                  Account.availableCurrencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency["code"],
                      child: Text(currency["label"]!),
                    );
                  }).toList(),
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
              focusNode: _balanceFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: buildInputDecoration(
                "Initial Value",
                prefixIcon: const Icon(Icons.attach_money),
                color: baseColor,
                isFocused: _focusedField == "balance",
                context: context,
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
              initialValue: _selectedCategory,
              focusNode: _categoryFocusNode,
              decoration: buildInputDecoration(
                "Category",
                prefixIcon: const Icon(Icons.category),
                color: baseColor,
                isFocused: _focusedField == "category",
                context: context,
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
            const SizedBox(height: 16),

            // 5. Color Selection
            Text(
              "Color",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ColorPickerGrid(
              colors: ColorUtils.availableColors,
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() => _selectedColor = color);
              },
            ),
            // Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _addAccount,
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
                        : Text(
                          widget.existingAccount != null
                              ? "Update Account"
                              : "Add Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
