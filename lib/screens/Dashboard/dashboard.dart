import 'package:flutter/material.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/screens/Rates/latest_rates.dart';
import 'package:mywallet/utils/WidgetHelper/add_transaction.dart';
import 'package:mywallet/widgets/Goal/goal_widget.dart';
import 'package:mywallet/widgets/Total_Balance/total_balance.dart';
import 'package:provider/provider.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedSection = "accounts";

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              GestureDetector(
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
              const SizedBox(width: 12),
              Text(
                'Welcome, ${profile?.username ?? 'User'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // ✅ Latest Rates Icon
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LatestRatesScreen(),
                    ),
                  );
                },
                child: Icon(Icons.show_chart, size: 28, color: baseColor),
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
            const TotalBalanceWidget(),

            // --- Pill Choice Buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPillButton("Accounts", "accounts"),
                  _buildPillButton("Bills", "bills"),
                  _buildPillButton("Goals", "goals"),
                ],
              ),
            ),

            if (selectedSection == "accounts") const AccountBalanceWidget(),
            if (selectedSection == "bills") const UpcomingBillsWidget(),
            if (selectedSection == "goals") const GoalsWidget(),

            const GraphsSectionWidget(),
          ],
        ),
      ),
      floatingActionButton:
          accounts.isEmpty
              ? null
              : FloatingActionButton(
                elevation: 0,
                backgroundColor: baseColor,
                foregroundColor: Theme.of(context).colorScheme.surface,
                onPressed: () => showAddTransactionModal(context, "records"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.surface.withAlpha(25),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
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

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSection = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? baseColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
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
        ),
      ),
    );
  }
}
