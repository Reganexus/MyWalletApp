import 'package:intl/intl.dart';

String formatBalance(String currency, double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: _currencySymbol(currency),
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String _currencySymbol(String currency) {
  switch (currency) {
    case "PHP":
      return "₱";
    case "USD":
      return "\$";
    case "EUR":
      return "€";
    default:
      return "$currency ";
  }
}
