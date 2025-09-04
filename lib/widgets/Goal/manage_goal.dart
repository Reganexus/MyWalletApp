import 'package:flutter/material.dart';
import 'package:mywallet/models/goal.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:mywallet/widgets/Goal/goal_form.dart';
import 'package:provider/provider.dart';

class ManageGoalsScreen extends StatefulWidget {
  const ManageGoalsScreen({super.key});

  @override
  State<ManageGoalsScreen> createState() => _ManageGoalsScreenState();
}

class _ManageGoalsScreenState extends State<ManageGoalsScreen> {
  Future<void> _editGoal(Goal goal) async {
    await showDraggableModal(
      context: context,
      child: GoalForm(existingGoal: goal),
    );

    if (!mounted) return;
    await ProviderReloader.reloadAll(context);
  }

  Future<void> _deleteGoal(Goal goal) async {
    final confirm = await showConfirmationDialog(
      context: context,
      title: "Delete Goal",
      content: "Are you sure you want to delete ${goal.name}?",
      confirmText: "Delete",
      confirmColor: Colors.red,
    );

    if (!mounted || confirm != true) return;

    try {
      await context.read<GoalProvider>().deleteGoal(goal.id!);

      if (!mounted) return;
      await ProviderReloader.reloadAll(context);

      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${goal.name} deleted successfully!",
      );
    } catch (e) {
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${goal.name} failed to delete: $e",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final goals = provider.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Goals"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body:
          goals.isEmpty
              ? const Center(child: Text("No goals found"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: goal.color.withValues(alpha: 0.2),
                        child: const Icon(Icons.flag, color: Colors.white),
                      ),
                      title: Text(
                        goal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Target: ${formatBalance(goal.currency, goal.targetAmount)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (goal.deadline != null)
                            Text(
                              "Deadline: ${formatFullDate(goal.deadline!)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          if (goal.customDeadline != null &&
                              goal.customDeadline!.isNotEmpty)
                            Text(
                              "Deadline: ${goal.customDeadline}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      title: const Text("Edit"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _editGoal(goal);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: const Text("Delete"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _deleteGoal(goal);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
