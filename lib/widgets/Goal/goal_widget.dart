import 'package:flutter/material.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:mywallet/utils/WidgetHelper/add_manage.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/services/layout_pref.dart';
import 'package:mywallet/utils/WidgetHelper/add_transaction.dart';
import 'package:mywallet/widgets/Goal/goal_empty.dart';
import 'package:mywallet/widgets/Goal/goal_form.dart';
import 'package:mywallet/widgets/Goal/goal_list_view.dart';
import 'package:mywallet/widgets/Goal/goal_manage.dart';
import 'package:provider/provider.dart';

class GoalsWidget extends StatefulWidget {
  const GoalsWidget({super.key});

  @override
  State<GoalsWidget> createState() => _GoalsWidgetState();
}

class _GoalsWidgetState extends State<GoalsWidget> {
  bool _isGrid = false;
  late final _layoutPref = const LayoutPreference("goals_isGrid");

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

  void _handleAddGoal() {
    showDraggableModal(
      context: context,
      child: const GoalForm(existingGoal: null),
    );
  }

  Future<void> _handleManageGoals() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageGoalsScreen()),
    );

    if (!mounted) return;

    if (updated == true) {
      context.read<GoalProvider>().loadGoals();
    }
  }

  void _handleContributeGoal() {
    showAddTransactionModal(context, "contribute");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        final goals = provider.goals;

        if (goals.isEmpty) {
          return EmptyGoalsState(onAdd: _handleAddGoal);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    "Goals",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _toggleLayout,
                    child: Icon(
                      _isGrid ? Icons.view_list : Icons.grid_view,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AccountActions(
                    onAdd: _handleAddGoal,
                    onManage: _handleManageGoals,
                    onContribute: _handleContributeGoal,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GoalListView(goals: goals, isGrid: _isGrid),
            ],
          ),
        );
      },
    );
  }
}
