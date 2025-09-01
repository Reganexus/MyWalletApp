import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/widgets/Account_Balance/account_form.dart';

Future<void> showAddAccountModal({
  required BuildContext context,
  Account? existingAccount,
}) async {
  await showDraggableModal(
    context: context,
    child: AccountForm(existingAccount: existingAccount),
  );
}
