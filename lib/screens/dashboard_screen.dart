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
        title: const Text(
          "Wallet Dashboard",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
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
            SizedBox(height: 16),
            AccountBalanceWidget(),
            SizedBox(height: 16),
            UpcomingBillsWidget(),
            SizedBox(height: 16),
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
