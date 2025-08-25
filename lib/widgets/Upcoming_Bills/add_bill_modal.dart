import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/color_utils.dart';
import 'package:mywallet/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class AddBillForm extends StatefulWidget {
  final Bill? existingBill;

  const AddBillForm({super.key, this.existingBill});

  @override
  State<AddBillForm> createState() => _AddBillFormState();
}

Future<void> showAddBillModal({
  required BuildContext context,
  Bill? existingBill,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder:
        (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder:
              (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 20,
                  ),
                  child: AddBillForm(existingBill: existingBill),
                ),
              ),
        ),
  );
}

class _AddBillFormState extends State<AddBillForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _dueDate = DateTime.now();
  BillStatus _status = BillStatus.pending;
  DateTime? _datePaid;
  Color _selectedColor = ColorUtils.availableColors.first;
  String? _selectedCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final bill = widget.existingBill;
    if (bill != null) {
      _nameController.text = bill.name;
      _amountController.text = bill.amount.toString();
      _dueDate = bill.dueDate;
      _status = bill.status;
      _datePaid = bill.datePaid;
      _selectedColor = bill.color;
      _selectedCurrency = bill.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickDatePaid() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _datePaid ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _datePaid = picked);
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final hex = ColorUtils.colorToHex(_selectedColor);
      final currency = _selectedCurrency ?? "PHP";

      final newBill = (widget.existingBill ??
              Bill(
                name: name,
                amount: amount,
                dueDate: _dueDate,
                status: _status,
                datePaid: _datePaid,
                colorHex: hex,
              ))
          .copyWith(
            name: name,
            amount: amount,
            dueDate: _dueDate,
            status: _status,
            datePaid: _datePaid,
            colorHex: hex,
            currency: currency,
          );

      final billsProvider = context.read<BillProvider>();

      if (widget.existingBill != null) {
        final confirm = await showConfirmationDialog(
          context: context,
          title: "Update Bill",
          content:
              "Do you want to save changes to ${widget.existingBill!.name}?",
          confirmText: "Update",
          confirmColor: Colors.blue,
        );
        if (confirm != true) return;

        await billsProvider.updateBill(newBill);
      } else {
        await billsProvider.addBill(newBill);
      }

      if (!mounted) return;
      await ProviderReloader.reloadAll(context);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save bill: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencies = context.watch<AccountProvider>().availableCurrencies;
    final currencyList = currencies.isNotEmpty ? currencies : ["PHP"];
    final dateFormatter = DateFormat.yMMMd();

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingBill != null ? "Update Bill" : "Add Bill",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "Bill Name",
              _nameController,
              "Please enter a name",
            ),
            const SizedBox(height: 12),
            _buildAmountField(),
            const SizedBox(height: 12),
            _buildCurrencyDropdown(currencyList),
            const SizedBox(height: 12),
            _buildDueDatePicker(dateFormatter),
            const SizedBox(height: 12),
            _buildStatusDropdown(),
            if (_status == BillStatus.paid) const SizedBox(height: 12),
            if (_status == BillStatus.paid) _buildDatePaidPicker(dateFormatter),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 16),
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String? validatorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) => (value == null || value.isEmpty) ? validatorMsg : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: "Amount",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter an amount';
        if (double.tryParse(value) == null) return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _buildCurrencyDropdown(List<String> currencies) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCurrency ?? currencies.first,
      decoration: const InputDecoration(
        labelText: "Currency",
        border: OutlineInputBorder(),
      ),
      items:
          currencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
      onChanged: (val) => setState(() => _selectedCurrency = val),
    );
  }

  Widget _buildDueDatePicker(DateFormat formatter) {
    return Row(
      children: [
        Expanded(child: Text("Due Date: ${formatter.format(_dueDate)}")),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickDueDate,
        ),
      ],
    );
  }

  Widget _buildDatePaidPicker(DateFormat formatter) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _datePaid == null
                ? "Date Paid: Not selected"
                : "Date Paid: ${formatter.format(_datePaid!)}",
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickDatePaid,
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<BillStatus>(
      initialValue: _status,
      decoration: const InputDecoration(
        labelText: "Status",
        border: OutlineInputBorder(),
      ),
      items:
          BillStatus.values
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                ),
              )
              .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _status = val);
      },
    );
  }

  Widget _buildColorPicker() {
    return GridView.count(
      crossAxisCount: 6,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
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
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveBill,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      child:
          _isLoading
              ? const CircularProgressIndicator.adaptive()
              : Text(widget.existingBill != null ? "Update Bill" : "Add Bill"),
    );
  }
}
