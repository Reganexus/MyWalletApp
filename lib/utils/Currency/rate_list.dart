import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/currencies.dart';
import 'package:mywallet/services/layout_pref.dart';
import 'package:provider/provider.dart';

class RatesList extends StatefulWidget {
  final Map<String, double> rates;
  final String? highlightCurrency;

  const RatesList({super.key, required this.rates, this.highlightCurrency});

  @override
  State<RatesList> createState() => _RatesListState();
}

class _RatesListState extends State<RatesList> {
  bool _isGrid = false;
  late final _layoutPref = const LayoutPreference("rates_list_isGrid");

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

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Column(
      children: [
        // Header
        Row(
          children: [
            const Text(
              'Other Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleLayout,
              child: Icon(
                _isGrid ? Icons.view_list : Icons.grid_view,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // List/Grid
        _isGrid
            ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.rates.length,
              itemBuilder: (context, index) {
                final key = widget.rates.keys.elementAt(index);
                final value = widget.rates[key]!;
                final name =
                    allCurrencies
                        .firstWhere(
                          (c) => c.code == key,
                          orElse: () => Currency(code: key, name: key),
                        )
                        .name;
                final highlight = key == widget.highlightCurrency;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: highlight ? baseColor : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '$name ($key)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.toStringAsFixed(4),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.rates.length,
              itemBuilder: (context, index) {
                final key = widget.rates.keys.elementAt(index);
                final value = widget.rates[key]!;
                final name =
                    allCurrencies
                        .firstWhere(
                          (c) => c.code == key,
                          orElse: () => Currency(code: key, name: key),
                        )
                        .name;
                final highlight = key == widget.highlightCurrency;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: highlight ? baseColor : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      '$name ($key)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: highlight ? Colors.white : null,
                      ),
                    ),
                    trailing: Text(
                      value.toStringAsFixed(4),
                      style: TextStyle(
                        fontSize: 14,
                        color: highlight ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}
