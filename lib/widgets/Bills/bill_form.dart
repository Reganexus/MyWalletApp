// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/currencies.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:mywallet/utils/WidgetHelper/color_picker.dart';
import 'package:mywallet/utils/Design/color_utils.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:mywallet/widgets/Bills/bill_disclaimer.dart';
import 'package:provider/provider.dart';

class BillForm extends StatefulWidget {
  final Bill? existingBill;

  const BillForm({super.key, this.existingBill});

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  // Focus tracking
  final _nameFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _currencyFocusNode = FocusNode();
  final _statusFocus = FocusNode();
  String? _focusedField;

  DateTime _dueDate = DateTime.now();
  BillStatus _status = BillStatus.pending;
  DateTime? _datePaid;
  Color _selectedColor = ColorUtils.availableColors.first;
  bool _isLoading = false;
  bool get _isEditable => widget.existingBill == null;
  String _selectedCurrency = "PHP";

  @override
  void initState() {
    super.initState();

    if (widget.existingBill != null) {
      _nameController.text = widget.existingBill!.name;
      _amountController.text = widget.existingBill!.amount.toString();
      _dueDate = widget.existingBill!.dueDate;
      _status = widget.existingBill!.status;
      _datePaid = widget.existingBill!.datePaid;
      _selectedColor = widget.existingBill!.color;
      _selectedCurrency = widget.existingBill!.currency;
    }

    // Attach listeners for focus tracking
    void attachListener(FocusNode node, String field) {
      node.addListener(() {
        if (node.hasFocus) {
          setState(() => _focusedField = field);
        } else if (_focusedField == field) {
          setState(() => _focusedField = null);
        }
      });
    }

    attachListener(_nameFocus, "name");
    attachListener(_amountFocus, "amount");
    attachListener(_currencyFocusNode, "currency");
    attachListener(_statusFocus, "status");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
    _currencyFocusNode.dispose();
    _statusFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    final theme = Theme.of(context);
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? tomorrow : (_datePaid ?? now),
      firstDate: isDueDate ? tomorrow : DateTime(now.year - 1),
      lastDate: isDueDate ? DateTime(now.year + 5, now.month, now.day) : now,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: baseColor,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
              secondary: baseColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: baseColor),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _datePaid = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = formatAccountName(_nameController.text.trim());
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final hex = ColorUtils.colorToHex(_selectedColor);

    final newBill = (widget.existingBill ??
            Bill(
              name: name,
              amount: amount,
              currency: _selectedCurrency,
              dueDate: _dueDate,
              status: _status,
              datePaid: _datePaid,
              colorHex: hex,
            ))
        .copyWith(
          name: name,
          amount: amount,
          currency: _selectedCurrency,
          dueDate: _dueDate,
          status: _status,
          datePaid: _datePaid,
          colorHex: hex,
        );

    final billsProvider = context.read<BillProvider>();

    if (widget.existingBill != null) {
      final confirm = await showConfirmationDialog(
        context: context,
        title: "Update Bill",
        content: "Do you want to save changes to ${widget.existingBill!.name}?",
        confirmText: "Update",
        confirmColor: baseColor,
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      // ⚠️ Skip scheduling & notifications for updates
      await billsProvider.updateBill(newBill);
    } else {
      // Only schedule notifications when adding a new bill
      await billsProvider.addBill(newBill);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final theme = Theme.of(context);

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.existingBill != null
                    ? "Update Monthly Bill"
                    : "Add Monthly Bill",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            BillDisclaimer(),
            const SizedBox(height: 20),

            // Bill Name
            TextFormField(
              controller: _nameController,
              enabled: _isEditable,
              focusNode: _nameFocus,
              decoration: buildInputDecoration(
                "Bill Name",
                prefixIcon: const Icon(Icons.receipt_long),
                color: baseColor,
                isFocused: _focusedField == "name",
                context: context,
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter a name'
                          : null,
              maxLength: 15,
            ),
            const SizedBox(height: 12),

            // Amount
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocus,
              enabled: _isEditable,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: buildInputDecoration(
                "Amount",
                prefixIcon: const Icon(Icons.attach_money),
                color: baseColor,
                isFocused: _focusedField == "amount",
                context: context,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Status
            DropdownButtonFormField<BillStatus>(
              focusNode: _statusFocus,
              initialValue: _status,
              decoration: buildInputDecoration(
                "Status",
                prefixIcon: const Icon(Icons.info),
                color: baseColor,
                isFocused: _focusedField == "status",
                context: context,
              ),
              items:
                  BillStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    );
                  }).toList(),
              onChanged:
                  _isEditable
                      ? (value) => setState(() => _status = value!)
                      : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              isExpanded: true,
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
                  allCurrencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency.code,
                      child: Text(
                        '${currency.code} - ${currency.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged:
                  _isEditable
                      ? (value) => setState(() => _selectedCurrency = value!)
                      : null,
            ),

            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Due Date",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.existingBill != null &&
                                        widget.existingBill!.status ==
                                            BillStatus.paid
                                    ? "${formatFullDate(_dueDate)} (next month)"
                                    : formatFullDate(_dueDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        if (_isEditable)
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            color: baseColor,
                            onPressed: () => _pickDate(isDueDate: true),
                          ),
                      ],
                    ),

                    // Date Paid Row (if status is paid)
                    if (_status == BillStatus.paid)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date Paid",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      _datePaid == null
                                          ? "Not selected"
                                          : formatFullDate(_datePaid!),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isEditable)
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  color: baseColor,
                                  onPressed: () => _pickDate(isDueDate: false),
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Color Picker
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
                if (widget.existingBill == null ||
                    widget.existingBill!.status == BillStatus.paid ||
                    widget.existingBill!.status != BillStatus.paid) {
                  setState(() => _selectedColor = color);
                }
              },
            ),

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
                        : Text(
                          widget.existingBill != null
                              ? "Update Monthly Bill"
                              : "Add Monthly Bill",
                          style: const TextStyle(
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
