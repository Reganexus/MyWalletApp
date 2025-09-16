import 'package:flutter/material.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';
import 'package:mywallet/utils/WidgetHelper/status_dropdown.dart';
import 'package:mywallet/widgets/Bills/bill_form.dart';
import 'package:provider/provider.dart';

class ManageBillsScreen extends StatefulWidget {
  const ManageBillsScreen({super.key});

  @override
  State<ManageBillsScreen> createState() => _ManageBillsScreenState();
}

class _ManageBillsScreenState extends State<ManageBillsScreen> {
  BillStatus? _selectedStatus;

  Future<void> _editBill(Bill bill) async {
    await showDraggableModal(
      context: context,
      child: BillForm(existingBill: bill),
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

      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${bill.name} deleted successfully!",
      );
    } catch (e) {
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${bill.name} failed to delete: '$e'",
      );
    }
  }

  Widget _buildStatusIndicator(BillStatus status) {
    return CircleAvatar(
      radius: 6,
      backgroundColor: status == BillStatus.paid ? Colors.green : Colors.orange,
    );
  }

  Widget _buildBillCard(Bill bill) {
    final dueDateStr = formatFullDate(bill.dueDate);
    final amountStr = formatNumber(bill.amount, currency: bill.currency);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: _buildStatusIndicator(bill.status),
        title: Text(
          bill.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              amountStr,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              "Due: $dueDateStr",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue),
                        title: const Text("Edit"),
                        onTap: () {
                          Navigator.pop(context);
                          _editBill(bill);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text("Delete"),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteBill(bill);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bills = context.watch<BillProvider>().bills;

    // check available statuses
    final hasPaid = bills.any((b) => b.status == BillStatus.paid);
    final hasPending = bills.any((b) => b.status == BillStatus.pending);

    // ✅ Apply filtering here
    final filteredBills =
        (_selectedStatus == null)
            ? bills
            : bills.where((b) => b.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Bills"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body:
          bills.isEmpty
              ? const Center(child: Text("No bills found"))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _buildLegendItem(Colors.green, "Paid"),
                        const SizedBox(width: 8),
                        _buildLegendItem(Colors.orange, "Unpaid"),
                        const Spacer(),
                        if (hasPaid && hasPending)
                          BillStatusFilter(
                            selectedStatus: _selectedStatus,
                            onChanged: (val) {
                              setState(() => _selectedStatus = val);
                            },
                          ),
                      ],
                    ),
                  ),

                  // ✅ Use filteredBills here
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredBills.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final bill = filteredBills[index];
                        return _buildBillCard(bill);
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
