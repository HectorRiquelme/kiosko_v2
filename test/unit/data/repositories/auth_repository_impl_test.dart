import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/data/repositories/auth_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/user.dart';

void main() {
  late AppDatabase db;
  late AuthRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AuthRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AuthRepositoryImpl', () {
    test('authenticateByPin returns admin user for correct PIN', () async {
      final user = await repo.authenticateByPin('1234');
      expect(user, isNotNull);
      expect(user!.role, UserRole.admin);
      expect(user.name, 'Administrador');
    });

    test('authenticateByPin returns worker for correct PIN', () async {
      final user = await repo.authenticateByPin('0000');
      expect(user, isNotNull);
      expect(user!.role, UserRole.worker);
      expect(user.name, 'Cocina 1');
    });

    test('authenticateByPin returns null for wrong PIN', () async {
      final user = await repo.authenticateByPin('9999');
      expect(user, isNull);
    });

    test('getAllUsers returns seeded users', () async {
      final users = await repo.getAllUsers();
      expect(users.length, 2);
    });

    test('createUser adds new user', () async {
      await repo.createUser(const AppUser(
        id: 'new1',
        name: 'Nuevo',
        pin: '5555',
        role: UserRole.worker,
      ));
      final user = await repo.authenticateByPin('5555');
      expect(user, isNotNull);
      expect(user!.name, 'Nuevo');
    });

    test('updateUser modifies existing user', () async {
      await repo.updateUser(const AppUser(
        id: 'worker1',
        name: 'Cocina Actualizada',
        pin: '1111',
        role: UserRole.worker,
      ));
      final user = await repo.authenticateByPin('1111');
      expect(user, isNotNull);
      expect(user!.name, 'Cocina Actualizada');
    });

    test('deleteUser removes user', () async {
      await repo.deleteUser('worker1');
      final users = await repo.getAllUsers();
      expect(users.length, 1);
    });
  });
}
