import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/add_modal.dart';
import 'package:mywallet/widgets/Upcoming_Bills/add_bill_modal.dart';
import 'package:mywallet/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class ManageBillsScreen extends StatefulWidget {
  const ManageBillsScreen({super.key});

  @override
  State<ManageBillsScreen> createState() => _ManageBillsScreenState();
}

class _ManageBillsScreenState extends State<ManageBillsScreen> {
  Future<void> _editBill(Bill bill) async {
    await showDraggableModal(
      context: context,
      child: AddBillForm(existingBill: bill),
    );
  }

  Future<void> _deleteBill(Bill bill) async {
    final confirm = await showConfirmationDialog(
      context: context,
      title: "Delete Bill",
      content: "Are you sure you want to delete ${bill.name}?",
      confirmText: "Delete",
      confirmColor: Colors.red,
    );

    if (!mounted || confirm != true) return;

    try {
      context.read<BillProvider>().deleteBill(bill.id!);
      await ProviderReloader.reloadAll(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete bill: $e")));
    }
  }

  Widget _buildStatusIndicator(BillStatus status) {
    return CircleAvatar(
      radius: 6,
      backgroundColor: status == BillStatus.paid ? Colors.green : Colors.orange,
    );
  }

  Widget _buildBillCard(Bill bill) {
    final dueDateStr = DateFormat.yMMMd().format(bill.dueDate);
    final amountStr = NumberFormat.currency(
      symbol: bill.currency,
    ).format(bill.amount);

    return Card(
      color: bill.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editBill(bill),
        child: ListTile(
          leading: _buildStatusIndicator(bill.status),
          title: Text(
            bill.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            "$amountStr - Due: $dueDateStr",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: "Edit Bill",
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editBill(bill),
                ),
              ),
              Tooltip(
                message: "Delete Bill",
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBill(bill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bills = context.watch<BillProvider>().bills;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bills")),
      body:
          bills.isEmpty
              ? const Center(child: Text("No bills found"))
              : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: bills.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return _buildBillCard(bill);
                },
              ),
    );
  }
}
