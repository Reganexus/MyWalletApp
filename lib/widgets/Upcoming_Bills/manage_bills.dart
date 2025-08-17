import 'package:flutter/material.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
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
    );

    if (!mounted || confirm != true) return;

    context.read<BillProvider>().deleteBill(bill.id!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final bills = provider.bills;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bills")),
      body:
          bills.isEmpty
              ? const Center(child: Text("No bills found"))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Card(
                    color: bill.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        bill.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "₱${bill.amount.toStringAsFixed(2)} - Due: ${bill.dueDate.toLocal().toString().split(" ")[0]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _editBill(bill),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBill(bill),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
