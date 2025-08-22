import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/screens/pin_screen.dart';
import 'services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final dbService = DBService(); // ✅ one instance

  await dbService.database; // ensures DB is ready

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => AccountProvider(db: dbService)..loadAccounts(),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => BillProvider(db: dbService)..loadBills(),
        ),
        ChangeNotifierProxyProvider<AccountProvider, TransactionProvider>(
          lazy: false,
          create: (_) => TransactionProvider(db: dbService),
          update: (_, accountProvider, txProvider) {
            txProvider!.accountProvider = accountProvider; // injected here
            return txProvider..loadTransactions();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PinScreen(mode: PinMode.unlock),
    );
  }
}
