import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/utils/WidgetHelper/add_transaction.dart';
import 'package:mywallet/widgets/Upcoming_Bills/bill_form.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/services/layout_pref.dart';
import 'package:mywallet/widgets/Upcoming_Bills/manage_bills.dart';
import 'package:mywallet/widgets/Upcoming_Bills/bill_list_view.dart';
import 'package:mywallet/widgets/Upcoming_Bills/bill_empty.dart';
import 'package:mywallet/utils/WidgetHelper/add_manage.dart';

class UpcomingBillsWidget extends StatefulWidget {
  const UpcomingBillsWidget({super.key});

  @override
  State<UpcomingBillsWidget> createState() => _UpcomingBillsWidgetState();
}

class _UpcomingBillsWidgetState extends State<UpcomingBillsWidget> {
  final formatter = DateFormat("yyyy-MM-dd");
  bool _isGrid = false;
  late final _layoutPref = const LayoutPreference("upcoming_bills_isGrid");

  @override
  void initState() {
    super.initState();
    _layoutPref.load().then((value) {
      if (mounted) setState(() => _isGrid = value);
    });
  }

  void _toggleLayout() {
    setState(() => _isGrid = !_isGrid);
    _layoutPref.save(_isGrid);
  }

  void _handleAddBill() {
    showDraggableModal(context: context, child: BillForm(existingBill: null));
  }

  Future<void> _handleManageBills() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageBillsScreen()),
    );

    if (!mounted) return;
    if (updated == true) {
      context.read<BillProvider>().loadBills();
    }
  }

  void _handlePayBill() {
    showAddTransactionModal(context, "bills");
  }

  bool isPaidThisMonth(Bill bill) {
    if (bill.status != BillStatus.paid || bill.datePaid == null) return false;
    final now = DateTime.now();
    return bill.datePaid!.year == now.year && bill.datePaid!.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, _) {
        final bills = provider.bills;

        if (bills.isEmpty) {
          return EmptyBillsState(onAdd: _handleAddBill);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                spacing: 0,
                children: [
                  const Text(
                    "Monthly Bills",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _toggleLayout,
                    child: Icon(
                      _isGrid ? Icons.view_list : Icons.grid_view,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AccountActions(
                    onAdd: _handleAddBill,
                    onManage: _handleManageBills,
                    onPay: _handlePayBill,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BillListView(
                bills: bills,
                isGrid: _isGrid,
                formatter: formatter,
                isPaidThisMonth: isPaidThisMonth,
              ),
            ],
          ),
        );
      },
    );
  }
}
