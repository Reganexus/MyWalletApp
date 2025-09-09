import 'package:flutter/material.dart';
import 'package:mywallet/models/bill.dart';

class BillStatusFilter extends StatelessWidget {
  final BillStatus? selectedStatus;
  final ValueChanged<BillStatus?> onChanged;
  final bool showAll;

  const BillStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<BillStatus?>(
      value: selectedStatus,
      isDense: true,
      hint: const Text("Filter"),
      items: [
        if (showAll) const DropdownMenuItem(value: null, child: Text("All")),
        const DropdownMenuItem(value: BillStatus.paid, child: Text("Paid")),
        const DropdownMenuItem(
          value: BillStatus.pending,
          child: Text("Pending"),
        ),
      ],
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      onChanged: onChanged,
    );
  }
}
