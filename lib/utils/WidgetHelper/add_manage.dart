import 'package:flutter/material.dart';

class AccountActions extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onManage;
  final VoidCallback? onPay;

  const AccountActions({
    super.key,
    required this.onAdd,
    required this.onManage,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) async {
        final value = await showMenu<int>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            const PopupMenuItem<int>(
              value: 0,
              child: Row(
                children: [Icon(Icons.add), SizedBox(width: 8), Text("Add")],
              ),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text("Manage"),
                ],
              ),
            ),
            if (onPay != null)
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.payment),
                    SizedBox(width: 8),
                    Text("Pay Bill"),
                  ],
                ),
              ),
          ],
        );

        if (value == 0) onAdd();
        if (value == 1) onManage();
        if (value == 2 && onPay != null) onPay!();
      },
      child: const Icon(Icons.more_vert, size: 24),
    );
  }
}
