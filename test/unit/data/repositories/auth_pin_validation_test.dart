import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/data/repositories/auth_repository_impl.dart';

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

  group('PIN validation', () {
    test('isPinAvailable returns false for existing PIN', () async {
      final available = await repo.isPinAvailable('1234');
      expect(available, false); // admin1 has PIN 1234
    });

    test('isPinAvailable returns true for unused PIN', () async {
      final available = await repo.isPinAvailable('9999');
      expect(available, true);
    });

    test('isPinAvailable excludes own user when editing', () async {
      final available =
          await repo.isPinAvailable('1234', excludeUserId: 'admin1');
      expect(available, true); // Same user can keep their PIN
    });

    test('isPinAvailable rejects if another user has it', () async {
      final available =
          await repo.isPinAvailable('1234', excludeUserId: 'worker1');
      expect(available, false); // worker1 trying to use admin1's PIN
    });
  });
}
