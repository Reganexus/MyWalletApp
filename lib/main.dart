import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mywallet/providers/multiprovider.dart';
import 'package:mywallet/providers/theme_provider.dart';
import 'package:mywallet/screens/Getting_Started/change_pin_starter.dart';
import 'package:mywallet/screens/Getting_Started/edit_profile_starter.dart';
import 'package:mywallet/screens/Getting_Started/get_started.dart';
import 'package:mywallet/screens/Dashboard/dashboard.dart';
import 'package:mywallet/screens/GraphOptions/graph_options.dart';
import 'package:mywallet/screens/Pin/pin.dart';
import 'package:mywallet/widgets/Sidebar/edit_profile_screen.dart';
import 'package:mywallet/widgets/Sidebar/backup_screen.dart';
import 'package:mywallet/widgets/Sidebar/delete_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/db_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dbService = DBService();
  await dbService.database;

  final prefs = await SharedPreferences.getInstance();
  final savedPin = prefs.getString("app_pin");

  await NotificationService.init();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  runApp(buildAppProviders(MyApp(hasPin: savedPin != null), dbService));
}

class MyApp extends StatelessWidget {
  final bool hasPin;
  const MyApp({super.key, required this.hasPin});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Wallet App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'SFPro',
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'SFPro',
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: hasPin ? '/pin' : '/get-started',
          routes: {
            '/get-started': (context) => const GetStartedScreen(),
            '/edit-profile-starter':
                (context) => const EditProfileStarterScreen(),
            '/change-pin-starter': (context) => const ChangePinStarterScreen(),
            '/pin':
                (context) =>
                    const PinScreen(mode: PinMode.unlock, hasPin: true),
            '/set-pin':
                (context) => const PinScreen(mode: PinMode.set, hasPin: false),
            '/dashboard': (context) => const DashboardScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/delete': (context) => const DeleteAllData(),
            '/backup': (context) => const BackupScreen(),
            '/graph-options': (_) => const GraphOptionsScreen(),
          },
        );
      },
    );
  }
}
