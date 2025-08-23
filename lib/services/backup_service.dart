import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Backup the DB by letting user pick a directory
  Future<File?> backupDatabase() async {
    // Pick a directory
    String? outputDir = await FilePicker.platform.getDirectoryPath();
    if (outputDir == null) return null;

    // Ensure database is closed before copying
    final dbService = DBService();
    final db = await dbService.database;
    await db.close();
    await dbService.resetDatabase();

    // Get DB file
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'mywallet.db'));

    // Copy to chosen folder
    final backupPath = join(outputDir, 'mywallet_backup.db');
    final backupFile = await dbFile.copy(backupPath);

    return backupFile;
  }

  /// Restore DB by letting user pick a .db file
  Future<void> restoreDatabase() async {
    // Let user pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result == null) {
      throw Exception("No file selected!");
    }

    final pickedFile = File(result.files.single.path!);

    if (await pickedFile.exists()) {
      // Close DB before restoring
      final dbService = DBService();
      final db = await dbService.database;
      await db.close();
      await dbService.resetDatabase();

      // Destination path (app's working DB)
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'mywallet.db');

      // Overwrite DB with the selected file
      await pickedFile.copy(path);
    } else {
      throw Exception("Selected file not found!");
    }
  }
}
