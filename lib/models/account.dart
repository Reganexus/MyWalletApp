import 'package:flutter/material.dart';
import 'package:mywallet/utils/Design/color_utils.dart';

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

  static const List<Map<String, String>> availableCurrencies = [
    {"code": "PHP", "label": "PHP - Philippine Peso"},
    {"code": "USD", "label": "USD - US Dollar"},
    {"code": "EUR", "label": "EUR - Euro"},
    {"code": "JPY", "label": "JPY - Japanese Yen"},
    {"code": "AUD", "label": "AUD - Australian Dollar"},
    {"code": "KRW", "label": "KRW - South Korean Won"},
    {"code": "CNY", "label": "CNY - Chinese Yuan"},
    {"code": "GBP", "label": "GBP - British Pound"},
    {"code": "CAD", "label": "CAD - Canadian Dollar"},
    {"code": "SGD", "label": "SGD - Singapore Dollar"},
    {"code": "HKD", "label": "HKD - Hong Kong Dollar"},
    {"code": "INR", "label": "INR - Indian Rupee"},
    {"code": "THB", "label": "THB - Thai Baht"},
    {"code": "IDR", "label": "IDR - Indonesian Rupiah"},
    {"code": "MYR", "label": "MYR - Malaysian Ringgit"},
  ];

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

  Color get color => ColorUtils.fromHex(colorHex);

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
}
