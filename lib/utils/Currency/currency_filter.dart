import 'package:flutter/material.dart';

class CurrencyFilter extends StatelessWidget {
  final List<String> currencies;
  final String? selectedCurrency;
  final ValueChanged<String?> onChanged;

  const CurrencyFilter({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (currencies.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: DropdownButton<String>(
        value: selectedCurrency,
        isDense: true,
        hint: const Text("Currency"),
        items:
            [
              "All",
              ...currencies,
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
