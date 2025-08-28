import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/widgets/Upcoming_Bills/bill_card.dart';

class BillListView extends StatelessWidget {
  final List<Bill> bills;
  final bool isGrid;
  final DateFormat formatter;
  final bool Function(Bill bill) isPaidThisMonth;

  const BillListView({
    super.key,
    required this.bills,
    required this.isGrid,
    required this.formatter,
    required this.isPaidThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bills.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          return BillCard(
            bill: bills[i],
            isPaidThisMonth: isPaidThisMonth(bills[i]),
            formatter: formatter,
            compact: true, // 👈 force compact in grid
          );
        },
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return BillCard(
          bill: bill,
          isPaidThisMonth: isPaidThisMonth(bill),
          formatter: formatter,
          compact: false, // 👈 explicit
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 16),
    );
  }
}
