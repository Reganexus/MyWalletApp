import 'package:mywallet/models/goal.dart';
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

    // Updated bills table schema
    await db.execute('''
    CREATE TABLE bills(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
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

    await db.execute('''
    CREATE TABLE goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      targetAmount REAL NOT NULL,
      savedAmount REAL NOT NULL DEFAULT 0,
      currency TEXT NOT NULL,
      deadline TEXT,
      customDeadline TEXT,
      colorHex TEXT NOT NULL,
      dateCreated TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
  ''');
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

  Future<int> deleteBill(int id) async {
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

  // ------------------ Goals ------------------

  Future<Goal> insertGoal(Goal goal) async {
    final db = await database;

    final now = DateTime.now();
    final goalToInsert = goal.copyWith(dateCreated: now, updatedAt: now);

    final id = await db.insert('goals', goalToInsert.toMap());
    return goalToInsert.copyWith(id: id);
  }

  Future<int> updateGoal(Goal goal) async {
    if (goal.id == null) {
      throw Exception("Cannot update a goal without an ID");
    }

    final db = await database;
    final updatedGoal = goal.copyWith(updatedAt: DateTime.now());

    return await db.update(
      'goals',
      updatedGoal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id!],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final maps = await db.query('goals');

    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
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
