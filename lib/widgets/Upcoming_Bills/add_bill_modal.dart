import 'package:flutter/material.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/widgets/Upcoming_Bills/bill_form.dart';

Future<void> showAddBillModal({
  required BuildContext context,
  Bill? existingBill,
}) async {
  await showDraggableModal(
    context: context,
    child: BillForm(existingBill: existingBill),
  );
}
