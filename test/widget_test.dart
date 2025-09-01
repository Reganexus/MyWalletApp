import 'package:flutter_test/flutter_test.dart';
import 'package:mywallet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString("app_pin");

    await tester.pumpWidget(MyApp(hasPin: savedPin != null));
  });
}
