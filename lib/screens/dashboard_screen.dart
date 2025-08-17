import 'package:flutter/material.dart';
import '../widgets/Account_Balance/account_balance_widget.dart';
import '../widgets/Upcoming_Bills/upcoming_bills_widget.dart';
import '../widgets/graphs_section_widget.dart';
import '../widgets/add_transaction_button.dart';
import '../widgets/profile_sidebar.dart';

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
            AccountBalanceWidget(),
            SizedBox(height: 16),
            UpcomingBillsWidget(),
            SizedBox(height: 16),
            GraphsSectionWidget(),
          ],
        ),
      ),
      floatingActionButton: const AddTransactionButton(),
    );
  }
}
