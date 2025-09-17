import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/graph_options_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';

class GraphOptionsScreen extends StatelessWidget {
  const GraphOptionsScreen({super.key});

  Widget _buildGraphCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String desc,
    required bool value,
    required VoidCallback onToggle,
    Color? color,
  }) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: (color ?? baseColor).withValues(alpha: 0.2),
              child: Icon(icon, color: color ?? baseColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) {
                final profile = profileProvider.profile;
                final userColor =
                    profile?.colorPreference != null
                        ? Color(int.parse(profile!.colorPreference!))
                        : Colors.blueGrey;

                return Switch(
                  value: value,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: Colors.white,
                  activeTrackColor: userColor,
                  inactiveThumbColor: userColor,
                  inactiveTrackColor: userColor.withValues(alpha: 0.5),
                  trackOutlineColor: WidgetStateProperty.all(Colors.white70),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphOptions = context.watch<GraphOptionsProvider>();

    final graphs = [
      {
        'key': 'weeklySpending',
        'title': 'Weekly Spending Heatmap',
        'desc': 'Visualizes daily spending intensity across the week.',
        'icon': Icons.calendar_view_week,
      },
      {
        'key': 'topExpense',
        'title': 'Top Expenses',
        'desc': 'Shows highest expense categories in a bar chart.',
        'icon': Icons.money_off,
      },
      {
        'key': 'incomeExpense',
        'title': 'Income vs Expense Trend',
        'desc': 'Line chart comparing income and expenses over time.',
        'icon': Icons.trending_up,
      },
      {
        'key': 'accountDistribution',
        'title': 'Account Distribution',
        'desc': 'Shows how funds are distributed across accounts.',
        'icon': Icons.account_balance_wallet,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Graph Options"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: ListView(
        children:
            graphs.map((g) {
              return _buildGraphCard(
                context: context,
                icon: g['icon'] as IconData,
                title: g['title'] as String,
                desc: g['desc'] as String,
                value: graphOptions.isGraphVisible(g['key'] as String),
                onToggle: () => graphOptions.toggleGraph(g['key'] as String),
              );
            }).toList(),
      ),
    );
  }
}
