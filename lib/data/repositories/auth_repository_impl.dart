import 'package:drift/drift.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/app_database.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;

  AuthRepositoryImpl(this._db);

  @override
  Future<AppUser?> authenticateByPin(String pin) async {
    final row = await (_db.select(_db.users)
          ..where((u) => u.pin.equals(pin)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final rows = await _db.select(_db.users).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> createUser(AppUser user) async {
    await _db.into(_db.users).insert(UsersCompanion(
          id: Value(user.id),
          name: Value(user.name),
          pin: Value(user.pin),
          role: Value(user.role.name),
        ));
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await (_db.update(_db.users)..where((u) => u.id.equals(user.id))).write(
      UsersCompanion(
        name: Value(user.name),
        pin: Value(user.pin),
        role: Value(user.role.name),
      ),
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    await (_db.delete(_db.users)..where((u) => u.id.equals(id))).go();
  }

  @override
  Future<bool> isPinAvailable(String pin, {String? excludeUserId}) async {
    final row = await (_db.select(_db.users)
          ..where((u) => u.pin.equals(pin)))
        .getSingleOrNull();
    if (row == null) return true;
    if (excludeUserId != null && row.id == excludeUserId) return true;
    return false;
  }

  AppUser _toEntity(User row) {
    return AppUser(
      id: row.id,
      name: row.name,
      pin: row.pin,
      role: row.role == 'admin' ? UserRole.admin : UserRole.worker,
    );
  }
}
