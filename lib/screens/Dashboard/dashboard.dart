// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/screens/Rates/latest_rates.dart';
import 'package:mywallet/utils/WidgetHelper/add_transaction.dart';
import 'package:mywallet/widgets/Goal/goal_widget.dart';
import 'package:mywallet/widgets/Total_Balance/total_balance.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../widgets/Account/account_widget.dart';
import '../../widgets/Bills/bill_widget.dart';
import '../../widgets/Graph/graph_wrapper.dart';
import '../../widgets/Sidebar/profile_sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late BuildContext showCaseContext;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Showcase Keys
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _ratesKey = GlobalKey();
  final GlobalKey _balanceKey = GlobalKey();
  final GlobalKey _accountsTabKey = GlobalKey();
  final GlobalKey _accountsWidgetKey = GlobalKey();
  final GlobalKey _billsTabKey = GlobalKey();
  final GlobalKey _billsWidgetKey = GlobalKey();
  final GlobalKey _goalsTabKey = GlobalKey();
  final GlobalKey _goalsWidgetKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  String selectedSection = "accounts";

  @override
  void initState() {
    super.initState();
    _checkIfTutorialNeeded();
  }

  Future<void> _checkIfTutorialNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialDone = prefs.getBool("tutorial_completed") ?? false;

    if (!tutorialDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final List<GlobalKey> showcaseKeys = [
          _profileKey,
          _ratesKey,
          _balanceKey,
          _accountsTabKey,
          _accountsWidgetKey,
          _billsTabKey,
          _billsWidgetKey,
          _goalsTabKey,
          _goalsWidgetKey,
          _fabKey,
        ];

        if (mounted) {
          ShowCaseWidget.of(showCaseContext).startShowCase(showcaseKeys);
        }
      });
    }
  }

  Future<void> _onTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("tutorial_completed", true);

    if (mounted) {
      setState(() {
        selectedSection = "accounts";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return ShowCaseWidget(
      onFinish: _onTutorialComplete,
      onStart: (index, key) {
        if (key == _billsTabKey) {
          if (mounted) {
            setState(() => selectedSection = "bills");
          }
        } else if (key == _goalsTabKey) {
          if (mounted) {
            setState(() => selectedSection = "goals");
          }
        } else if (key == _fabKey) {
          if (mounted) {
            setState(() => selectedSection = "accounts");
          }
        }
      },
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          backgroundColor: baseColor,
          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          name: "Next",
          onTap: () {
            ShowCaseWidget.of(showCaseContext).next();
          },
        ),
      ],
      builder: (context) {
        showCaseContext = context;
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            scrolledUnderElevation: 0.0,
            elevation: 0.0,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Showcase(
                    key: _profileKey,
                    description:
                        "This is your profile. Tap to open the sidebar.",
                    child: GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: baseColor,
                        backgroundImage:
                            profile?.profileImage != null
                                ? MemoryImage(profile!.profileImage!)
                                : null,
                        child:
                            profile?.profileImage == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    profile?.username ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Showcase(
                    key: _ratesKey,
                    description: "Check the latest currency rates here.",
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LatestRatesScreen(),
                          ),
                        );
                      },
                      child: Icon(Icons.show_chart, size: 28, color: baseColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawer: const ProfileSidebar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Showcase(
                  key: _balanceKey,
                  onToolTipClick: () {
                    setState(() {
                      selectedSection = "accounts";
                    });
                  },
                  description: "Here you can see your total balance.",
                  child: const TotalBalanceWidget(),
                ),

                // --- Pill Choice Buttons ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Showcase(
                          key: _accountsTabKey,
                          description: "Switch to Accounts tab here.",
                          child: _buildPillButton("Accounts", "accounts"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Showcase(
                          key: _billsTabKey,
                          description: "Switch to Bills tab here.",
                          child: _buildPillButton("Bills", "bills"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Showcase(
                          key: _goalsTabKey,
                          description: "Switch to Goals tab here.",
                          child: _buildPillButton("Goals", "goals"),
                        ),
                      ),
                    ],
                  ),
                ),

                if (selectedSection == "accounts")
                  Showcase(
                    key: _accountsWidgetKey,
                    description: "Your accounts are listed here.",
                    child: const AccountBalanceWidget(),
                  ),

                if (selectedSection == "bills")
                  Showcase(
                    key: _billsWidgetKey,
                    description: "Your upcoming bills will appear here.",
                    child: const UpcomingBillsWidget(),
                  ),

                if (selectedSection == "goals")
                  Showcase(
                    key: _goalsWidgetKey,
                    description: "Your goals are displayed here.",
                    child: const GoalsWidget(),
                  ),
                GraphsSectionWidget(),
              ],
            ),
          ),
          floatingActionButton:
              accounts.isEmpty
                  ? null
                  : Showcase(
                    key: _fabKey,
                    description:
                        "Tap here to add a new transaction. Available when you have accounts.",
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: baseColor,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      onPressed:
                          () => showAddTransactionModal(context, "records"),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(25),
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
        );
      },
    );
  }

  // --- Pill Button Builder ---
  Widget _buildPillButton(String label, String value) {
    final bool isSelected = selectedSection == value;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = value;
        });
      },
      child: Container(
        alignment: Alignment.center, // center the text
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? baseColor : Colors.transparent,
              width: 3, // full width of button
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isSelected
                    ? baseColor
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
