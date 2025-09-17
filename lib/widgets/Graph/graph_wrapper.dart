import 'package:flutter/material.dart';
import 'package:mywallet/providers/graph_options_provider.dart';
import 'package:mywallet/widgets/Graph/Graphs/graph_top_expense.dart';
import 'package:mywallet/widgets/Graph/Graphs/graph_weekly_spending.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/widgets/Graph/Graphs/graph_account_distribution.dart';
import 'package:mywallet/widgets/Graph/Graphs/graph_income_expense.dart';

class GraphsSectionWidget extends StatelessWidget {
  const GraphsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final transactions = context.watch<TransactionProvider>().transactions;
    final graphOptions = context.watch<GraphOptionsProvider>();

    return Column(
      children: [
        if (graphOptions.isGraphVisible('weeklySpending'))
          WeeklySpendingHeatmap(transactions: transactions),
        if (graphOptions.isGraphVisible('topExpense'))
          TopExpenseGraph(transactions: transactions),
        if (graphOptions.isGraphVisible('incomeExpense'))
          IncomeExpenseTrendGraph(transactions: transactions),
        if (graphOptions.isGraphVisible('accountDistribution'))
          AccountDistributionGraph(accounts: accounts),
      ],
    );
  }
}
