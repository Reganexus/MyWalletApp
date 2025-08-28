import 'package:intl/intl.dart';

String formatDay(int date) {
  final dayFormatter = date;

  if (dayFormatter == 1) {
    return "${dayFormatter}st";
  } else if (dayFormatter == 2) {
    return "${dayFormatter}nd";
  } else if (dayFormatter == 3) {
    return "${dayFormatter}rd";
  } else {
    return "${dayFormatter}th";
  }
}

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

String formatFullBalance(double amount, {required String currency}) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: _currencySymbol(currency),
    decimalDigits: 2, // always show cents
  );
  return formatter.format(amount);
}

/// For shortened numbers (K, M, no decimals for small numbers)
String formatNumber(double value, {required String currency}) {
  final symbol = _currencySymbol(currency);

  if (value >= 1000000) {
    return "$symbol${(value / 1000000).toStringAsFixed(1)}M";
  } else if (value >= 1000) {
    return "$symbol${(value / 1000).toStringAsFixed(1)}K";
  } else {
    return "$symbol${value.toStringAsFixed(0)}";
  }
}
