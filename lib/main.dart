import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mywallet/providers/transaction_provider.dart';
import 'package:mywallet/screens/dashboard_screen.dart';
import 'package:mywallet/widgets/Sidebar/backup_screen.dart';
import 'package:mywallet/widgets/Sidebar/delete_data.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/theme_provider.dart';
import 'package:mywallet/screens/pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final dbService = DBService();
  await dbService.database;

  final prefs = await SharedPreferences.getInstance();
  final savedPin = prefs.getString("app_pin");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => AccountProvider(db: dbService),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => BillProvider(db: dbService),
        ),
        ChangeNotifierProxyProvider<AccountProvider, TransactionProvider>(
          lazy: false,
          create: (_) => TransactionProvider(db: dbService),
          update: (_, accountProvider, txProvider) {
            txProvider!.accountProvider = accountProvider;
            return txProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(
        initialMode: savedPin == null ? PinMode.set : PinMode.unlock,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final PinMode initialMode;
  const MyApp({super.key, required this.initialMode});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Wallet App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          initialRoute: '/pin',
          routes: {
            '/pin': (context) => PinScreen(mode: initialMode),
            '/dashboard': (context) => const DashboardScreen(),
            '/delete': (context) => const DeleteAllData(),
            '/backup': (context) => const BackupScreen(),
          },
        );
      },
    );
  }
}
