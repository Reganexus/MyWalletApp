class TransactionModel {
  final int? id;
  final int accountId;
  final String type;
  final String category;
  final double amount;
  final DateTime date;
  final String? note;

  TransactionModel({
    this.id,
    required this.accountId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      type: map['type'] as String,
      category: map['category'] ?? "",
      amount: map['amount'] as double,
      date: DateTime.parse(map['date']),
      note: map['note'] as String?,
    );
  }
}
