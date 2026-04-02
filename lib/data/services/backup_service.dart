import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class BackupService {
  static Future<String> get _dbPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'kiosko_v2.sqlite');
  }

  static Future<String> get _backupDir async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  /// Create a backup of the current database
  static Future<String?> createBackup() async {
    if (kIsWeb) return null;
    try {
      final dbFile = File(await _dbPath);
      if (!await dbFile.exists()) return null;

      final dir = await _backupDir;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = p.join(dir, 'kiosko_backup_$timestamp.sqlite');

      await dbFile.copy(backupPath);
      return backupPath;
    } catch (_) {
      return null;
    }
  }

  /// List available backups sorted by date (newest first)
  static Future<List<BackupInfo>> listBackups() async {
    if (kIsWeb) return [];
    try {
      final dir = Directory(await _backupDir);
      if (!await dir.exists()) return [];

      final files = await dir
          .list()
          .where((f) => f.path.endsWith('.sqlite'))
          .toList();

      final backups = <BackupInfo>[];
      for (final file in files) {
        final stat = await file.stat();
        backups.add(BackupInfo(
          path: file.path,
          name: p.basename(file.path),
          size: stat.size,
          createdAt: stat.modified,
        ));
      }

      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (_) {
      return [];
    }
  }

  /// Restore database from a backup file.
  /// IMPORTANT: App must be restarted after restore.
  static Future<bool> restoreBackup(String backupPath) async {
    if (kIsWeb) return false;
    try {
      final dbPath = await _dbPath;
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) return false;

      // Create safety backup of current DB before overwriting
      final currentDb = File(dbPath);
      if (await currentDb.exists()) {
        final dir = await _backupDir;
        final safetyPath = p.join(dir, 'pre_restore_safety.sqlite');
        await currentDb.copy(safetyPath);
      }

      // Overwrite current DB with backup
      await backupFile.copy(dbPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete a backup file
  static Future<bool> deleteBackup(String path) async {
    if (kIsWeb) return false;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get the size of the current database
  static Future<int> getDatabaseSize() async {
    if (kIsWeb) return 0;
    try {
      final file = File(await _dbPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}

class BackupInfo {
  final String path;
  final String name;
  final int size;
  final DateTime createdAt;

  const BackupInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.createdAt,
  });

  String get sizeLabel {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
