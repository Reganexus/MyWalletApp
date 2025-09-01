import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Design/chart_legend.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:provider/provider.dart';

class AccountDistributionGraph extends StatefulWidget {
  final List<Account> accounts;

  const AccountDistributionGraph({super.key, required this.accounts});

  @override
  State<AccountDistributionGraph> createState() =>
      _AccountDistributionGraphState();
}

class _AccountDistributionGraphState extends State<AccountDistributionGraph> {
  String? _selectedCurrency;
  Map<Account, double> _convertedBalances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _updateBalances();
  }

  // ADDED: The key fix is here
  @override
  void didUpdateWidget(covariant AccountDistributionGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accounts != oldWidget.accounts) {
      _updateBalances();
    }
  }

  Future<void> _updateBalances() async {
    setState(() => _loading = true);
    final accounts = context.read<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();

    // CORRECTED: Check if the currencies list is empty
    if (currencies.isNotEmpty) {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
      }
    } else {
      _selectedCurrency = null; // Set to null if there are no accounts
    }

    Map<Account, double> newBalances = {};
    // CORRECTED: Only proceed if a currency is selected
    if (_selectedCurrency != null) {
      for (var account in widget.accounts) {
        double balance = account.balance;
        if (account.currency != _selectedCurrency) {
          final rate = await ForexService.getRate(
            account.currency,
            _selectedCurrency!,
          );
          if (rate != null) balance *= rate;
        }
        newBalances[account] = balance;
      }
    }

    setState(() {
      _convertedBalances = newBalances;
      _loading = false;
    });
  }

  List<BarChartGroupData> get bars {
    final sorted =
        _convertedBalances.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final accountBalance = entry.value.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: accountBalance,
            width: 250 / _convertedBalances.length,
            borderRadius: BorderRadius.circular(6),
            color: Colors.primaries[index % Colors.primaries.length].withAlpha(
              199,
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Account> get sortedAccounts {
    final entries = _convertedBalances.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final accounts = context.watch<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();

    // Check for empty accounts list and reset state
    bool needsUpdate = false;
    if (accounts.isEmpty) {
      if (_selectedCurrency != null) {
        _selectedCurrency = null;
        needsUpdate = true;
      }
      if (_convertedBalances.isNotEmpty) {
        _convertedBalances = {};
        needsUpdate = true;
      }
    } else {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
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
    final profile = context.watch<ProfileProvider>().profile;

    final currencies = accounts.map((a) => a.currency).toSet().toList();
    final showDropdown = currencies.length > 1;
    final chartBars = bars;
    final chartAccounts = sortedAccounts;
    final labels = chartAccounts.map((a) => a.name).toList();
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    if (accounts.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Account Distribution",
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
                    barGroups: chartBars,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipBorderRadius: BorderRadius.circular(8),
                        getTooltipColor:
                            (group) =>
                                group.barRods.first.color ?? Colors.black,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final account = chartAccounts[group.x];
                          final value = formatNumber(
                            rod.toY,
                            currency: _selectedCurrency ?? 'PHP',
                          );
                          return BarTooltipItem(
                            "${account.name}\n$value",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget:
                              (value, meta) => Text(
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
          ChartLegend(labels: labels),
        ],
      ),
    );
  }
}
