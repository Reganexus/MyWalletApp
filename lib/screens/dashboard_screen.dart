import 'package:flutter/material.dart';
import 'package:mywallet/utils/add_transaction.dart';
import 'package:mywallet/widgets/Total_Balance/total_balance.dart';
import '../widgets/Account_Balance/account_balance_widget.dart';
import '../widgets/Upcoming_Bills/upcoming_bills_widget.dart';
import '../widgets/Graph_Section/graph_wrapper.dart';
import '../widgets/Sidebar/profile_sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Wallet Dashboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),

      drawer: const ProfileSidebar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            TotalBalanceWidget(),
            AccountBalanceWidget(),
            UpcomingBillsWidget(),
            GraphsSectionWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTransactionModal(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
