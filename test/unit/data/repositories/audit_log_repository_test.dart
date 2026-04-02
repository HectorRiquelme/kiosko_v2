import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/data/repositories/audit_log_repository.dart';
import 'package:kiosko_v2/domain/entities/audit_log_entry.dart';

void main() {
  late AppDatabase db;
  late AuditLogRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AuditLogRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AuditLogRepository', () {
    test('starts with seeded logs', () async {
      final logs = await repo.getAll();
      expect(logs.length, 7);
    });

    test('log creates an entry', () async {
      final before = await repo.getAll();
      await repo.log(
        userId: 'admin1',
        userName: 'Admin',
        action: AuditAction.create,
        entityType: AuditEntityType.product,
        entityId: 'cap',
        entityName: 'Cappuccino',
        details: 'Precio: \$3.500',
      );

      final logs = await repo.getAll();
      expect(logs.length, before.length + 1);
      expect(logs.first.entityName, 'Cappuccino');
      expect(logs.first.action, AuditAction.create);
      expect(logs.first.userName, 'Admin');
    });

    test('getByEntityType filters correctly', () async {
      final productLogsBefore = await repo.getByEntityType(AuditEntityType.product);
      await repo.log(
        userId: 'admin1', userName: 'Admin',
        action: AuditAction.create, entityType: AuditEntityType.product,
        entityId: '1', entityName: 'Producto',
      );
      await repo.log(
        userId: 'admin1', userName: 'Admin',
        action: AuditAction.create, entityType: AuditEntityType.category,
        entityId: '2', entityName: 'Categoria',
      );

      final productLogs = await repo.getByEntityType(AuditEntityType.product);
      expect(productLogs.length, productLogsBefore.length + 1);
      expect(productLogs.first.entityName, 'Producto');
    });

    test('getSales returns only sale entries', () async {
      final salesBefore = await repo.getSales();
      expect(salesBefore.length, 3); // 3 seeded sale entries
      await repo.log(
        userId: 'system', userName: 'Sistema',
        action: AuditAction.sale, entityType: AuditEntityType.order,
        entityId: '1', entityName: 'Pedido #1',
      );
      await repo.log(
        userId: 'admin1', userName: 'Admin',
        action: AuditAction.create, entityType: AuditEntityType.product,
        entityId: '2', entityName: 'Producto',
      );

      final sales = await repo.getSales();
      expect(sales.length, salesBefore.length + 1);
      for (final s in sales) {
        expect(s.action, AuditAction.sale);
      }
    });

    test('getByUser filters by userId', () async {
      final adminBefore = await repo.getByUser('admin1');
      expect(adminBefore.length, 3); // 3 seeded admin1 entries
      await repo.log(
        userId: 'admin1', userName: 'Admin',
        action: AuditAction.create, entityType: AuditEntityType.product,
        entityId: '1', entityName: 'P1',
      );
      await repo.log(
        userId: 'worker1', userName: 'Cocina',
        action: AuditAction.login, entityType: AuditEntityType.user,
        entityId: 'worker1', entityName: 'Cocina',
      );

      final adminLogs = await repo.getByUser('admin1');
      expect(adminLogs.length, adminBefore.length + 1);
      for (final l in adminLogs) {
        expect(l.userId, 'admin1');
      }
    });

    test('can retrieve logs with limit', () async {
      for (int i = 0; i < 5; i++) {
        await repo.log(
          userId: 'a', userName: 'A',
          action: AuditAction.create, entityType: AuditEntityType.product,
          entityId: '$i', entityName: 'Product $i',
        );
      }

      final logs = await repo.getAll(limit: 3);
      expect(logs.length, 3);
    });
  });
}
