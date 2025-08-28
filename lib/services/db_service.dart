import 'package:mywallet/models/profile.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/bill.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mywallet.db');
    return _database!;
  }

  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('accounts');
    await db.delete('bills');
    await db.delete('transactions');
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ---------------- Schema ----------------
    await db.execute('''
    CREATE TABLE profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      profile_image BLOB,
      color_preference TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE accounts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT NOT NULL,
      name TEXT NOT NULL,
      currency TEXT NOT NULL,
      balance REAL NOT NULL,
      colorHex TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE bills(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      amount REAL NOT NULL,
      status TEXT NOT NULL,
      dueDate TEXT NOT NULL,
      datePaid TEXT,
      colorHex TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      account_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      category TEXT,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    )
  ''');

    // ---------------- Seed Data ----------------

    // Accounts
    await db.insert('accounts', {
      'category': 'Bank',
      'name': 'BDO Checking',
      'currency': 'PHP',
      'balance': 12000.0,
      'colorHex': '#2196F3',
    });
    await db.insert('accounts', {
      'category': 'Cash',
      'name': 'Wallet',
      'currency': 'PHP',
      'balance': 2500.0,
      'colorHex': '#4CAF50',
    });
    await db.insert('accounts', {
      'category': 'E-Wallet',
      'name': 'GCash',
      'currency': 'PHP',
      'balance': 5000.0,
      'colorHex': '#9C27B0',
    });

    // Bills
    final now = DateTime.now();
    final bills = [
      {
        'id': 'bill-001',
        'name': 'Electricity',
        'amount': 2200.0,
        'status': 'pending',
        'dueDate': now.add(const Duration(days: 5)).toIso8601String(),
        'datePaid': null,
        'colorHex': '#FF9800',
      },
      {
        'id': 'bill-002',
        'name': 'Water',
        'amount': 800.0,
        'status': 'pending',
        'dueDate': now.add(const Duration(days: 10)).toIso8601String(),
        'datePaid': null,
        'colorHex': '#03A9F4',
      },
      {
        'id': 'bill-003',
        'name': 'Internet',
        'amount': 1500.0,
        'status': 'paid',
        'dueDate': now.subtract(const Duration(days: 2)).toIso8601String(),
        'datePaid': now.subtract(const Duration(days: 1)).toIso8601String(),
        'colorHex': '#673AB7',
      },
    ];
    for (var bill in bills) {
      await db.insert('bills', bill);
    }

    // ---------------- Transactions ----------------
    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Entertainment',
      'Groceries',
      'Salary',
      'Cashback',
      'Investment',
      'Health',
    ];

    final notes = [
      'Jollibee meal',
      'Grab ride',
      'Shopee purchase',
      'Meralco bill',
      'Netflix subscription',
      'SM Hypermarket',
      'Salary credit',
      'GCash promo',
      'Stocks top-up',
      'Pharmacy',
    ];

    // Generate 50+ transactions (mix of income/expense across accounts)
    for (int i = 0; i < 55; i++) {
      final accountId = (i % 3) + 1; // cycle through 1, 2, 3
      final type = (i % 7 == 0) ? 'income' : 'expense'; // ~1 in 7 is income
      final category = categories[i % categories.length];
      final note = notes[i % notes.length];
      final amount =
          (type == 'income')
              ? 5000 +
                  (i * 100) // salary/income bigger
              : 100 + (i * 20); // expenses smaller
      final date = now.subtract(Duration(days: i)).toIso8601String();

      await db.insert('transactions', {
        'account_id': accountId,
        'type': type,
        'category': category,
        'amount': amount.toDouble(),
        'date': date,
        'note': note,
      });
    }
  }

  // ------------------ Accounts ------------------

  Future<Account> insertAccount(Account account) async {
    final db = await database;
    final id = await db.insert('accounts', account.toMap());
    return account.copyWith(id: id);
  }

  Future<int> updateAccount(Account account) async {
    if (account.id == null) {
      throw Exception("Cannot update an account without an ID");
    }
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id!],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Account>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  // ------------------ Bills ------------------

  Future<Bill> insertBill(Bill bill) async {
    final db = await database;
    await db.insert('bills', bill.toMap());
    return bill;
  }

  Future<int> updateBill(Bill bill) async {
    final db = await database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(String id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Bill>> getBills() async {
    final db = await database;
    final maps = await db.query('bills');
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // ------------------ Transaction ------------------

  // Insert a transaction
  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap());
  }

  // Get all transactions (order by latest)
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // Delete transaction by id
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Update a transaction (by id)
  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    if (tx.id == null) {
      throw Exception("Cannot update a transaction without an ID");
    }

    final map = tx.toMap();
    map.remove('id');

    return await db.update(
      'transactions',
      map,
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<List<String>> getCurrencies() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT currency FROM accounts');
    return result.map((row) => row['currency'] as String).toList();
  }

  Future<int> saveProfile(Profile profile) async {
    final db = await database;
    return await db.insert(
      'profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Profile?> getProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    if (result.isNotEmpty) {
      return Profile.fromMap(result.first);
    }
    return null;
  }
}
