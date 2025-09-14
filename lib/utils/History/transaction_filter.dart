import 'package:flutter/material.dart';
import 'package:mywallet/utils/History/filter_options.dart';

class TypeFilterDropdown extends StatelessWidget {
  final TransactionTypeFilter selectedType;
  final ValueChanged<TransactionTypeFilter> onChanged;

  const TypeFilterDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TransactionTypeFilter>(
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      value: selectedType,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(
          value: TransactionTypeFilter.all,
          child: Text("All Types"),
        ),
        DropdownMenuItem(
          value: TransactionTypeFilter.income,
          child: Text("Income"),
        ),
        DropdownMenuItem(
          value: TransactionTypeFilter.expense,
          child: Text("Expense"),
        ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
