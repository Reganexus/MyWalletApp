import 'package:flutter/material.dart';

enum AccountCategory { bank, cash, crypto, investment, ewallet, other }

const Map<AccountCategory, IconData> categoryIcons = {
  AccountCategory.bank: Icons.account_balance,
  AccountCategory.cash: Icons.money,
  AccountCategory.crypto: Icons.currency_bitcoin,
  AccountCategory.investment: Icons.trending_up,
  AccountCategory.ewallet: Icons.account_balance_wallet,
  AccountCategory.other: Icons.help_outline,
};

const Map<AccountCategory, String> categoryLabels = {
  AccountCategory.bank: "Bank",
  AccountCategory.cash: "Cash",
  AccountCategory.crypto: "Crypto",
  AccountCategory.investment: "Investment",
  AccountCategory.ewallet: "E-wallet",
  AccountCategory.other: "Other",
};

const List<Color> availableColors = [
  Colors.blue,
  Colors.indigo,
  Colors.deepPurple,
  Colors.purple,
  Colors.red,
  Colors.deepOrange,
  Colors.teal,
  Colors.green,
  Colors.brown,
  Colors.pink,
  Colors.cyan,
  Colors.blueGrey,
  Colors.grey,
];

class Account {
  final int? id;
  final AccountCategory category;
  final String name;
  final String currency;
  final double balance;
  final String colorHex;

  Account({
    this.id,
    required this.category,
    required this.name,
    required this.currency,
    required this.balance,
    this.colorHex = "#4285F4",
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id!,
      'category': category.name,
      'name': name,
      'currency': currency,
      'balance': balance,
      'colorHex': colorHex,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      category: AccountCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AccountCategory.ewallet,
      ),
      name: map['name'] as String,
      currency: map['currency'] as String,
      balance: (map['balance'] as num).toDouble(),
      colorHex: map['colorHex'] as String? ?? "#4285F4",
    );
  }

  Color get color => _colorFromHex(colorHex);

  IconData get icon => categoryIcons[category]!;

  Account copyWith({
    int? id,
    AccountCategory? category,
    String? name,
    String? currency,
    double? balance,
    String? colorHex,
  }) {
    return Account(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  static Color _colorFromHex(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  static String colorToHex(Color color, {bool includeAlpha = false}) {
    final argb = color.toARGB32();
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;

    return includeAlpha
        ? '#${a.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
        : '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}
