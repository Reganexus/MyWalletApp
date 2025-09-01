import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:intl/intl.dart';

enum FilterOption { today, week, month, all, custom }

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  FilterOption _selectedFilter = FilterOption.all;
  DateTimeRange? _customRange;

  List<DateTime> _getRangeDates() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case FilterOption.today:
        return [DateTime(now.year, now.month, now.day), now];
      case FilterOption.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return [
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          now,
        ];
      case FilterOption.month:
        return [DateTime(now.year, now.month, 1), now];
      case FilterOption.custom:
        return _customRange != null
            ? [_customRange!.start, _customRange!.end]
            : [DateTime(2000), now];
      case FilterOption.all:
        return [DateTime(2000), now];
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();

    final transactions = txProvider.transactions;
    final range = _getRangeDates();

    final filteredTx =
        transactions.where((tx) {
          return tx.date.isAfter(range[0]) &&
              tx.date.isBefore(range[1].add(const Duration(days: 1)));
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Legend + Dropdown in a single row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildLegendItem(Colors.green, "Income"),
                const SizedBox(width: 8),
                _buildLegendItem(Colors.red, "Expense"),
                const Spacer(),
                DropdownButton<FilterOption>(
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: FilterOption.today,
                      child: Text("Today"),
                    ),
                    DropdownMenuItem(
                      value: FilterOption.week,
                      child: Text("This Week"),
                    ),
                    DropdownMenuItem(
                      value: FilterOption.month,
                      child: Text("This Month"),
                    ),
                    DropdownMenuItem(
                      value: FilterOption.all,
                      child: Text("All Time"),
                    ),
                    DropdownMenuItem(
                      value: FilterOption.custom,
                      child: Text("Custom"),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == FilterOption.custom) {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        initialDateRange:
                            _customRange ??
                            DateTimeRange(
                              start: DateTime.now().subtract(
                                const Duration(days: 7),
                              ),
                              end: DateTime.now(),
                            ),
                      );
                      if (picked != null) {
                        setState(() {
                          _customRange = picked;
                          _selectedFilter = FilterOption.custom;
                        });
                      }
                    } else {
                      setState(() => _selectedFilter = value!);
                    }
                  },
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child:
                filteredTx.isEmpty
                    ? const Center(
                      child: Text(
                        "No transactions for this period.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredTx.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTx[index];
                        final account = accountProvider.accounts.firstWhere(
                          (a) => a.id == tx.accountId,
                        );
                        final formattedDate = DateFormat.yMMMd().format(
                          tx.date,
                        );

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  tx.type == "income"
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                              child: Icon(
                                tx.type == "income"
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color:
                                    tx.type == "income"
                                        ? Colors.green
                                        : Colors.red,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              "${tx.category} • ${account.name}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle:
                                tx.note != null && tx.note!.isNotEmpty
                                    ? Text(
                                      tx.note!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                    : null,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${account.currency} ${tx.amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color:
                                        tx.type == "income"
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
