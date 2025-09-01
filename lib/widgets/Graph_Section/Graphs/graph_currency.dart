import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Design/chart_legend.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:provider/provider.dart';

class BalanceByCurrencyChart extends StatefulWidget {
  final List<Account> accounts;

  const BalanceByCurrencyChart({super.key, required this.accounts});

  @override
  State<BalanceByCurrencyChart> createState() => _BalanceByCurrencyChartState();
}

class _BalanceByCurrencyChartState extends State<BalanceByCurrencyChart> {
  String? _selectedCurrency;
  Map<String, double> _convertedBalances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _updateBalances();
  }

  // ADDED: The key fix for dynamic updates.
  @override
  void didUpdateWidget(covariant BalanceByCurrencyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the list of accounts has changed.
    if (widget.accounts != oldWidget.accounts) {
      _updateBalances();
    }
  }

  Future<void> _updateBalances() async {
    setState(() => _loading = true);

    final accounts = context.read<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();

    // CORRECTED: Check if the list is empty before accessing its first element.
    if (currencies.isNotEmpty) {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
      }
    } else {
      _selectedCurrency = null;
    }

    Map<String, double> newBalances = {};
    // CORRECTED: Do not proceed if no currency is selected
    if (_selectedCurrency != null) {
      for (var account in accounts) {
        double balance = account.balance;

        if (account.currency != _selectedCurrency) {
          final rate = await ForexService.getRate(
            account.currency,
            _selectedCurrency!,
          );
          if (rate != null) balance *= rate;
        }

        newBalances[account.currency] =
            (newBalances[account.currency] ?? 0) + balance;
      }
    }

    setState(() {
      _convertedBalances = newBalances;
      _loading = false;
    });
  }

  List<BarChartGroupData> get _bars {
    if (_convertedBalances.isEmpty) {
      return [];
    }

    final sorted =
        _convertedBalances.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value,
            width: 250 / _convertedBalances.length,
            borderRadius: BorderRadius.circular(6),
            color: Colors.primaries[i % Colors.primaries.length].withAlpha(199),
          ),
        ],
      );
    }).toList();
  }

  List<String> get _labels {
    final sorted =
        _convertedBalances.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final accounts = context.watch<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();

    bool needsUpdate = false;

    // CORRECTED: Handle case where account list becomes empty
    if (accounts.isEmpty) {
      if (_convertedBalances.isNotEmpty) {
        _convertedBalances = {};
        needsUpdate = true;
      }
    } else {
      for (var a in accounts) {
        if (!_convertedBalances.containsKey(a.currency)) {
          needsUpdate = true;
          break;
        }
      }
    }

    // CORRECTED: Check for empty list before accessing first element
    if (currencies.isNotEmpty) {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
        needsUpdate = true;
      }
    } else {
      // If there are no currencies, set selected currency to null to avoid errors.
      if (_selectedCurrency != null) {
        _selectedCurrency = null;
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      _updateBalances();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();
    final showDropdown = currencies.length > 1;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    // CORRECTED: The check is now for the accounts list itself
    if (accounts.isEmpty || currencies.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Balance by Currency",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (showDropdown)
                DropdownButton<String>(
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  value: _selectedCurrency,
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() => _selectedCurrency = value);
                    await _updateBalances();
                  },
                  items:
                      currencies
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart
          _loading
              ? Center(child: CircularProgressIndicator(color: baseColor))
              : SizedBox(
                height: 250,
                child: BarChart(
                  key: ValueKey(_selectedCurrency),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: _bars,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget:
                              (value, meta) => Text(
                                // CORRECTED: Add null check for _selectedCurrency
                                formatNumber(
                                  value,
                                  currency: _selectedCurrency ?? 'PHP',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        tooltipBorderRadius: BorderRadius.circular(8),
                        getTooltipColor:
                            (group) =>
                                group.barRods.first.color ?? Colors.black,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final currency = _labels[group.x];
                          final value = formatNumber(
                            rod.toY,
                            // CORRECTED: Add null check for _selectedCurrency
                            currency: _selectedCurrency ?? 'PHP',
                          );
                          return BarTooltipItem(
                            "$currency\n$value",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: Colors.grey.withAlpha(40),
                            strokeWidth: 1,
                          ),
                    ),
                  ),
                ),
              ),

          const SizedBox(height: 24),

          // Legend
          ChartLegend(labels: _labels),
        ],
      ),
    );
  }
}
