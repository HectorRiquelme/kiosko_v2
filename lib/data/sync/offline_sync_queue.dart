import 'dart:collection';
import '../../domain/entities/order.dart';

enum SyncStatus { pending, syncing, synced, failed }

class SyncEntry {
  final String id;
  final Order order;
  SyncStatus status;
  int retryCount;
  DateTime createdAt;

  SyncEntry({
    required this.id,
    required this.order,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class OfflineSyncQueue {
  final Queue<SyncEntry> _queue = Queue();
  static const int maxRetries = 3;

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  List<SyncEntry> get entries => _queue.toList();

  void enqueue(Order order) {
    _queue.add(SyncEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      order: order,
    ));
  }

  SyncEntry? peek() => _queue.isEmpty ? null : _queue.first;

  SyncEntry? dequeue() => _queue.isEmpty ? null : _queue.removeFirst();

  void markFailed(SyncEntry entry) {
    entry.retryCount++;
    if (entry.retryCount < maxRetries) {
      entry.status = SyncStatus.pending;
      _queue.add(entry);
    } else {
      entry.status = SyncStatus.failed;
      // TODO: Persist permanently failed entries for manual review
    }
  }

  void markSynced(SyncEntry entry) {
    entry.status = SyncStatus.synced;
  }

  List<SyncEntry> getPending() {
    return _queue.where((e) => e.status == SyncStatus.pending).toList();
  }

  void clear() => _queue.clear();
}
