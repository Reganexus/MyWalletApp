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
    symbol: currencySymbol(currency),
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String currencySymbol(String currency) {
  switch (currency) {
    case "PHP":
      return "₱";
    case "USD":
      return "\$";
    case "EUR":
      return "€";
    case "JPY":
      return "¥";
    case "GBP":
      return "£";
    case "AUD":
      return "A\$";
    case "CAD":
      return "C\$";
    case "SGD":
      return "S\$";
    case "HKD":
      return "HK\$";
    case "INR":
      return "₹";
    case "KRW":
      return "₩";
    case "CNY":
      return "¥";
    case "THB":
      return "฿";
    case "IDR":
      return "Rp";
    case "MYR":
      return "RM";
    default:
      return currency.trim().isEmpty ? "?" : currency;
  }
}

String formatFullBalance(double amount, {required String currency}) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: currencySymbol(currency),
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String formatNumber(double value, {required String currency}) {
  final symbol = currencySymbol(currency);

  if (value >= 1000000) {
    return "$symbol${(value / 1000000).toStringAsFixed(1)}M";
  } else if (value >= 1000) {
    return "$symbol${(value / 1000).toStringAsFixed(1)}K";
  } else {
    // If whole number, no decimals, otherwise show 2 decimals
    return value % 1 == 0
        ? "$symbol${value.toStringAsFixed(0)}"
        : "$symbol${value.toStringAsFixed(2)}";
  }
}

String formatFullDate(DateTime date) {
  final formatter = DateFormat('MMMM d, yyyy');
  return formatter.format(date);
}

String formatFullDateTime(DateTime date) {
  final formatter = DateFormat('MMMM d, yyyy h:mm a');
  return formatter.format(date);
}
