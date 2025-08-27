import 'package:flutter/material.dart';
import 'package:mywallet/widgets/Graph_Section/Graphs/graph_top_expense.dart';
import 'package:mywallet/widgets/Graph_Section/Graphs/graph_weekly_spending.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/widgets/Graph_Section/Graphs/graph_account_distribution.dart';
import 'package:mywallet/widgets/Graph_Section/Graphs/graph_currency.dart';
import 'package:mywallet/widgets/Graph_Section/Graphs/graph_income_expense.dart';

class GraphsSectionWidget extends StatelessWidget {
  const GraphsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final transactions = context.watch<TransactionProvider>().transactions;

    return Column(
      children: [
        TopExpenseGraph(transactions: transactions),
        SizedBox(height: 16),
        BalanceByCurrencyChart(accounts: accounts),
        SizedBox(height: 16),
        IncomeExpenseTrendGraph(transactions: transactions),
        SizedBox(height: 16),
        WeeklySpendingHeatmap(transactions: transactions),
        SizedBox(height: 16),
        AccountDistributionGraph(accounts: accounts),
      ],
    );
  }
}
