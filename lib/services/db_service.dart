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

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
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
}
