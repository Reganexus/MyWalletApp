import 'package:flutter/material.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/utils/color_utils.dart';
import 'package:mywallet/utils/confirmation_dialog.dart';
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
                child: AddBillForm(existingBill: existingBill),
              ),
            ),
          );
        },
      );
    },
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
  bool _isLoading = false;

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

  Future<void> _addBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final hex = ColorUtils.colorToHex(_selectedColor);

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
        );

    final billsProvider = context.read<BillProvider>();

    if (widget.existingBill != null) {
      final confirm = await showConfirmationDialog(
        context: context,
        title: "Update Bill",
        content: "Do you want to save changes to ${widget.existingBill!.name}?",
        confirmText: "Update",
        confirmColor: Colors.blue,
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      await billsProvider.updateBill(newBill);
    } else {
      await billsProvider.addBill(newBill);
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
              widget.existingBill != null ? "Update Bill" : "Add Bill",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 1. Bill Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Bill Name",
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? 'Please enter a name'
                          : null,
            ),
            const SizedBox(height: 12),

            // 2. Amount
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
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

            // 3. Due Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDueDate,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Status
            DropdownButtonFormField<BillStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items:
                  BillStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 12),

            // 5. Date Paid (only if Paid)
            if (_status == BillStatus.paid)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _datePaid == null
                          ? "Date Paid: Not selected"
                          : "Date Paid: ${_datePaid!.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDatePaid,
                  ),
                ],
              ),
            if (_status == BillStatus.paid) const SizedBox(height: 12),

            // 6. Color Selection
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
              onPressed: _isLoading ? null : _addBill,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : Text(
                        widget.existingBill != null
                            ? "Update Bill"
                            : "Add Bill",
                      ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
