import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/utils/History/transaction_filter.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/utils/History/account_filter.dart';
import 'package:mywallet/utils/History/filter_options.dart';
import 'package:mywallet/utils/History/time_filter.dart';
import 'package:mywallet/utils/WidgetHelper/add_transaction.dart';
import 'package:mywallet/widgets/Sidebar/empty_transactions.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  TransactionTypeFilter _selectedType = TransactionTypeFilter.all;
  FilterOption _selectedFilter = FilterOption.all;
  DateTimeRange? _customRange;
  Account? _selectedAccount;

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

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();

    final transactions = txProvider.transactions;
    final accounts = accountProvider.accounts;
    final range = _getRangeDates();

    final filteredTx =
        transactions.where((tx) {
          final inDateRange =
              tx.date.isAfter(range[0]) &&
              tx.date.isBefore(range[1].add(const Duration(days: 1)));

          final matchesAccount =
              _selectedAccount == null || tx.accountId == _selectedAccount?.id;

          final matchesType =
              _selectedType == TransactionTypeFilter.all ||
              (_selectedType == TransactionTypeFilter.income &&
                  tx.type == "income") ||
              (_selectedType == TransactionTypeFilter.expense &&
                  tx.type == "expense");

          return inDateRange && matchesAccount && matchesType;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 🔹 Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Legend Row (Bottom)
                Row(
                  children: [
                    _buildLegendItem(Colors.green, "Income"),
                    const SizedBox(width: 12),
                    _buildLegendItem(Colors.red, "Expense"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AccountFilterDropdown(
                        accounts: accounts,
                        selectedAccount: _selectedAccount,
                        onChanged:
                            (account) =>
                                setState(() => _selectedAccount = account),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TimeFilterDropdown(
                        selectedFilter: _selectedFilter,
                        onChanged: (filter) async {
                          if (filter == FilterOption.custom) {
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
                            setState(() => _selectedFilter = filter);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TypeFilterDropdown(
                        selectedType: _selectedType,
                        onChanged:
                            (type) => setState(() => _selectedType = type),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Transaction List
          Expanded(
            child:
                filteredTx.isEmpty
                    ? EmptyTransactionsState(
                      onAdd: () => showAddTransactionModal(context, "records"),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredTx.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTx[index];
                        final account = accounts.firstWhere(
                          (a) => a.id == tx.accountId,
                        );
                        final formattedDate = DateFormat.yMMMd().format(
                          tx.date,
                        );

                        return _buildTransactionCard(
                          tx,
                          account,
                          formattedDate,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
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

  Widget _buildTransactionCard(
    TransactionModel tx,
    Account account,
    String formattedDate,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: (tx.type == "income" ? Colors.green : Colors.red)
              .withAlpha(50),
          child: Icon(
            tx.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
            color: tx.type == "income" ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          tx.category,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
              ),
            ),
            if (tx.note != null && tx.note!.isNotEmpty)
              Text(
                tx.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${account.currency} ${tx.amount.toStringAsFixed(2)}",
              style: TextStyle(
                color: tx.type == "income" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
