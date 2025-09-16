import 'package:flutter/material.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/widgets/Transaction/add_transaction_button.dart';

Future<void> showAddTransactionModal(
  BuildContext context,
  String section,
) async {
  await showDraggableModal(
    context: context,
    child: AccountBillsSwitcher(initialSection: section),
  );
}
