import 'package:flutter/material.dart';
import 'package:mywallet/utils/History/filter_options.dart';

class TimeFilterDropdown extends StatelessWidget {
  final FilterOption selectedFilter;
  final ValueChanged<FilterOption> onChanged;

  const TimeFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<FilterOption>(
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      value: selectedFilter,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: FilterOption.today, child: Text("Today")),
        DropdownMenuItem(value: FilterOption.week, child: Text("This Week")),
        DropdownMenuItem(value: FilterOption.month, child: Text("This Month")),
        DropdownMenuItem(value: FilterOption.all, child: Text("All Time")),
        DropdownMenuItem(value: FilterOption.custom, child: Text("Custom")),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
