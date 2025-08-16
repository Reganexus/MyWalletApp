import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mywallet/models/account.dart';

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
  }

  // Insert a new account
  Future<Account> insertAccount(Account account) async {
    final db = await database;
    final id = await db.insert('accounts', account.toMap());
    return account.copyWith(id: id);
  }

  // Update an account
  Future<int> updateAccount(Account account) async {
    if (account.id == null) {
      throw Exception("Cannot update an account without an ID");
    }
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id!], // id is guaranteed non-null here
    );
  }

  // Delete an account
  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // Get all accounts
  Future<List<Account>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }
}
