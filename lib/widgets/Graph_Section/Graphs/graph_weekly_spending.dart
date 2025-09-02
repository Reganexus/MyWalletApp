import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:provider/provider.dart';

class WeeklySpendingHeatmap extends StatefulWidget {
  final List<TransactionModel> transactions;

  const WeeklySpendingHeatmap({super.key, required this.transactions});

  @override
  State<WeeklySpendingHeatmap> createState() => _WeeklySpendingHeatmapState();
}

class _WeeklySpendingHeatmapState extends State<WeeklySpendingHeatmap> {
  String? _selectedCurrency;
  Map<int, String> _accountCurrencyMap = {};
  bool _loading = true;
  List<double> _monthlySpending = [];
  int _firstDayOfMonthWeekday = 0;
  bool _hasSpending = false;
  int _daysInMonth = 0;

  @override
  void initState() {
    super.initState();
    _updateSpending();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSpending();
  }

  @override
  void didUpdateWidget(covariant WeeklySpendingHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactions != oldWidget.transactions) {
      _updateSpending();
    }
  }

  Future<void> _updateSpending() async {
    setState(() => _loading = true);

    final accounts = context.read<AccountProvider>().accounts;
    _accountCurrencyMap = {for (var a in accounts) a.id!: a.currency};
    final currencies = _accountCurrencyMap.values.toSet().toList();

    if (currencies.isNotEmpty) {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
      }
    } else {
      _selectedCurrency = null;
    }

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    // Correcting weekday to be 0-indexed (Monday = 0)
    _firstDayOfMonthWeekday = (firstDay.weekday - 1 + 7) % 7;
    // Get the total number of days in the current month
    _daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    _monthlySpending = List.filled(_daysInMonth, 0);
    _hasSpending = false;

    if (_selectedCurrency != null) {
      final currentMonthExpenses =
          widget.transactions.where((tx) {
            return tx.type == 'expense' &&
                tx.date.year == now.year &&
                tx.date.month == now.month;
          }).toList();

      if (currentMonthExpenses.isNotEmpty) {
        _hasSpending = true;
      }

      for (var tx in currentMonthExpenses) {
        final accountCurrency = _accountCurrencyMap[tx.accountId] ?? 'PHP';
        double amount = tx.amount;

        if (accountCurrency != _selectedCurrency) {
          final rate = await ForexService.getRate(
            accountCurrency,
            _selectedCurrency!,
          );
          if (rate != null) amount *= rate;
        }

        int dayOfMonth = tx.date.day;
        // Since list is 0-indexed, we subtract 1 from the day of the month
        if (dayOfMonth - 1 < _monthlySpending.length) {
          _monthlySpending[dayOfMonth - 1] += amount;
        }
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final accounts = context.watch<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();
    final showDropdown = currencies.length > 1;

    double maxSpending =
        _monthlySpending.isEmpty
            ? 0
            : _monthlySpending.fold(0.0, (p, e) => e > p ? e : p);
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    if (!_hasSpending || _monthlySpending.isEmpty) {
      return const SizedBox.shrink();
    }

    final int totalCells = _daysInMonth + _firstDayOfMonthWeekday;
    final int rowCount = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monthly Spending",
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
                    await _updateSpending();
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
              : LayoutBuilder(
                builder: (context, constraints) {
                  double cellSize = (constraints.maxWidth - 6 * 4) / 7;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            const [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun',
                                ]
                                .map(
                                  (d) => SizedBox(
                                    width: cellSize,
                                    child: Center(
                                      child: Text(
                                        d,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height:
                            rowCount > 0
                                ? cellSize * rowCount + (rowCount - 1) * 4
                                : 0,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                          itemCount: totalCells,
                          itemBuilder: (context, index) {
                            final dayOfMonth =
                                index - _firstDayOfMonthWeekday + 1;
                            final bool isValidDate =
                                dayOfMonth > 0 && dayOfMonth <= _daysInMonth;

                            double value =
                                isValidDate
                                    ? _monthlySpending[dayOfMonth - 1]
                                    : 0.0;

                            int alpha =
                                maxSpending == 0 || value == 0
                                    ? 0
                                    : ((value / maxSpending) * 200 + 55)
                                        .clamp(55, 255)
                                        .toInt();

                            final Color cellColor;
                            final Color textColor;
                            final String displayText;

                            if (isValidDate) {
                              if (value > 0) {
                                cellColor = baseColor.withAlpha(alpha);
                                textColor = Colors.white;
                                displayText = formatNumber(
                                  value,
                                  currency: _selectedCurrency ?? 'PHP',
                                );
                              } else {
                                cellColor = Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(20);
                                textColor =
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color ??
                                    Colors.black;
                                displayText = dayOfMonth.toString();
                              }
                            } else {
                              cellColor = Colors.transparent;
                              textColor = Colors.transparent;
                              displayText = '';
                            }

                            return Tooltip(
                              message:
                                  isValidDate
                                      ? "${DateFormat('MMM d, y').format(DateTime(DateTime.now().year, DateTime.now().month, dayOfMonth))}\n"
                                          "Spending: ${formatNumber(value, currency: _selectedCurrency ?? 'PHP')}"
                                      : "Invalid Date",
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: cellColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    displayText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
        ],
      ),
    );
  }
}
