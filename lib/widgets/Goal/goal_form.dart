// lib/widgets/Goals/goal_form.dart
import 'package:flutter/material.dart';
import 'package:mywallet/models/goal.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/currencies.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/Design/color_utils.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:mywallet/utils/WidgetHelper/color_picker.dart';
import 'package:provider/provider.dart';

class GoalForm extends StatefulWidget {
  final Goal? existingGoal;
  const GoalForm({super.key, this.existingGoal});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _customDeadlineController = TextEditingController();

  // focus tracking
  final _nameFocusNode = FocusNode();
  final _targetAmountFocusNode = FocusNode();
  final _currencyFocusNode = FocusNode();
  final _deadlineFocusNode = FocusNode();
  String? _focusedField;

  String _selectedCurrency = "PHP";
  DateTime? _deadline;
  bool _useFixedDeadline = false;
  Color _selectedColor = ColorUtils.availableColors.first;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // attach focus listeners
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
    attachListener(_targetAmountFocusNode, "amount");
    attachListener(_currencyFocusNode, "currency");
    attachListener(_deadlineFocusNode, "deadline");

    // prefill if editing
    if (widget.existingGoal != null) {
      final g = widget.existingGoal!;
      _nameController.text = g.name;
      _targetAmountController.text = g.targetAmount.toString();
      _customDeadlineController.text = g.customDeadline ?? "";
      _selectedCurrency = g.currency;
      _deadline = g.deadline;
      _useFixedDeadline = g.deadline != null;
      _selectedColor = g.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _customDeadlineController.dispose();
    _nameFocusNode.dispose();
    _targetAmountFocusNode.dispose();
    _currencyFocusNode.dispose();
    _deadlineFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initial = _deadline ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _saveGoal() async {
    final profile = context.read<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newGoal = (widget.existingGoal ??
            Goal(
              name: _nameController.text.trim(),
              targetAmount: double.tryParse(_targetAmountController.text) ?? 0,
              savedAmount: widget.existingGoal?.savedAmount ?? 0,
              currency: _selectedCurrency,
              deadline: _useFixedDeadline ? _deadline : null,
              customDeadline:
                  !_useFixedDeadline
                      ? _customDeadlineController.text.trim()
                      : null,
              colorHex: ColorUtils.colorToHex(_selectedColor),
              dateCreated: DateTime.now(),
              updatedAt: DateTime.now(),
            ))
        .copyWith(
          name: _nameController.text.trim(),
          targetAmount: double.tryParse(_targetAmountController.text) ?? 0,
          currency: _selectedCurrency,
          deadline: _useFixedDeadline ? _deadline : null,
          customDeadline:
              !_useFixedDeadline ? _customDeadlineController.text.trim() : null,
          colorHex: ColorUtils.colorToHex(_selectedColor),
          updatedAt: DateTime.now(),
        );

    final goalProvider = context.read<GoalProvider>();

    if (widget.existingGoal != null) {
      final confirm = await showConfirmationDialog(
        context: context,
        title: "Update Goal",
        content: "Do you want to save changes to ${widget.existingGoal!.name}?",
        confirmText: "Update",
        confirmColor: baseColor,
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      await goalProvider.updateGoal(newGoal);
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${newGoal.name} updated successfully!",
      );
    } else {
      await goalProvider.addGoal(newGoal);
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${newGoal.name} added successfully!",
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
            // Title
            Center(
              child: Text(
                widget.existingGoal != null ? "Update Goal" : "Add Goal",
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
                "Goal Name",
                prefixIcon: const Icon(Icons.flag),
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

            // 2. Target Amount
            TextFormField(
              controller: _targetAmountController,
              focusNode: _targetAmountFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: buildInputDecoration(
                "Target Amount",
                prefixIcon: const Icon(Icons.attach_money),
                color: baseColor,
                isFocused: _focusedField == "amount",
                context: context,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 3. Currency
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
                      child: Text('${currency.code} - ${currency.name}'),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCurrency = value);
              },
            ),
            const SizedBox(height: 12),

            // 4. Deadline toggle
            Row(
              children: [
                Checkbox(
                  value: _useFixedDeadline,
                  onChanged: (val) {
                    setState(() => _useFixedDeadline = val ?? false);
                  },
                ),
                const Text("Add a fixed date"),
              ],
            ),
            if (_useFixedDeadline) ...[
              GestureDetector(
                onTap: _pickDeadline,
                child: InputDecorator(
                  decoration: buildInputDecoration(
                    "Deadline",
                    prefixIcon: const Icon(Icons.date_range),
                    color: baseColor,
                    isFocused: _focusedField == "deadline",
                    context: context,
                  ),
                  child: Text(
                    _deadline != null
                        ? formatFullDate(_deadline!)
                        : "Tap to pick a date",
                  ),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _customDeadlineController,
                focusNode: _deadlineFocusNode,
                decoration: buildInputDecoration(
                  "Custom Deadline",
                  prefixIcon: const Icon(Icons.edit_calendar),
                  color: baseColor,
                  isFocused: _focusedField == "deadline",
                  context: context,
                ),
              ),
            ],
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

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveGoal,
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
                        : Text(
                          widget.existingGoal != null
                              ? "Update Goal"
                              : "Add Goal",
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
