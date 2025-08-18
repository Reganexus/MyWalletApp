import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/providers/account_provider.dart';

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
        final startOfMonth = DateTime(now.year, now.month, 1);
        return [startOfMonth, now];
      case FilterOption.custom:
        if (_customRange != null) {
          return [_customRange!.start, _customRange!.end];
        }
        return [DateTime(2000), now];
      case FilterOption.all:
        return [DateTime(2000), now];
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();

    final transactions = txProvider.transactions;

    // Apply filtering
    final range = _getRangeDates();
    final filteredTx =
        transactions.where((tx) {
          return tx.date.isAfter(range[0]) &&
              tx.date.isBefore(range[1].add(const Duration(days: 1)));
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.blueGrey,
        actions: [
          DropdownButton<FilterOption>(
            value: _selectedFilter,
            underline: const SizedBox(),
            dropdownColor: Colors.blueGrey[50],
            items: const [
              DropdownMenuItem(value: FilterOption.today, child: Text("Today")),
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
                child: Text("Custom Range"),
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
                        start: DateTime.now().subtract(const Duration(days: 7)),
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
                setState(() {
                  _selectedFilter = value!;
                });
              }
            },
          ),
        ],
      ),
      body:
          filteredTx.isEmpty
              ? const Center(
                child: Text(
                  "No transactions for this period.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: filteredTx.length,
                itemBuilder: (context, index) {
                  final tx = filteredTx[index];
                  final account = accountProvider.accounts.firstWhere(
                    (a) => a.id == tx.accountId,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            tx.type == "income" ? Colors.green : Colors.red,
                        child: Icon(
                          tx.type == "income"
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                      title: Text("${tx.category} • ${account.name}"),
                      subtitle: Text(
                        tx.note ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                            ),
                          ),
                          Text(
                            "${tx.date.toLocal()}".split(" ")[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
