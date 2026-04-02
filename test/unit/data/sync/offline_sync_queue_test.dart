import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/sync/offline_sync_queue.dart';
import 'package:kiosko_v2/domain/entities/order.dart';

void main() {
  group('OfflineSyncQueue', () {
    late OfflineSyncQueue queue;

    final testOrder = Order(
      id: '1',
      items: [],
      totalInCents: 350000,
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cash,
      queueNumber: 1,
      createdAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      queue = OfflineSyncQueue();
    });

    test('starts empty', () {
      expect(queue.isEmpty, true);
      expect(queue.length, 0);
    });

    test('enqueue adds entry', () {
      queue.enqueue(testOrder);
      expect(queue.length, 1);
      expect(queue.isEmpty, false);
    });

    test('peek returns first without removing', () {
      queue.enqueue(testOrder);
      final entry = queue.peek();
      expect(entry, isNotNull);
      expect(queue.length, 1);
    });

    test('dequeue removes and returns first', () {
      queue.enqueue(testOrder);
      final entry = queue.dequeue();
      expect(entry, isNotNull);
      expect(queue.isEmpty, true);
    });

    test('dequeue returns null when empty', () {
      expect(queue.dequeue(), isNull);
    });

    test('peek returns null when empty', () {
      expect(queue.peek(), isNull);
    });

    test('markSynced sets status', () {
      queue.enqueue(testOrder);
      final entry = queue.dequeue()!;
      queue.markSynced(entry);
      expect(entry.status, SyncStatus.synced);
    });

    test('markFailed re-queues under max retries', () {
      queue.enqueue(testOrder);
      final entry = queue.dequeue()!;
      queue.markFailed(entry);
      expect(queue.length, 1); // Re-queued
      expect(entry.retryCount, 1);
    });

    test('markFailed drops after max retries', () {
      queue.enqueue(testOrder);
      final entry = queue.dequeue()!;

      // Fail 3 times
      queue.markFailed(entry); // retry 1, re-queued
      queue.dequeue();
      queue.markFailed(entry); // retry 2, re-queued
      queue.dequeue();
      queue.markFailed(entry); // retry 3, NOT re-queued

      expect(queue.isEmpty, true);
      expect(entry.status, SyncStatus.failed);
    });

    test('clear empties queue', () {
      queue.enqueue(testOrder);
      queue.enqueue(testOrder);
      queue.clear();
      expect(queue.isEmpty, true);
    });

    test('getPending returns pending entries', () {
      queue.enqueue(testOrder);
      queue.enqueue(testOrder);
      expect(queue.getPending().length, 2);
    });

    test('entries returns list copy', () {
      queue.enqueue(testOrder);
      final entries = queue.entries;
      expect(entries.length, 1);
    });
  });
}
