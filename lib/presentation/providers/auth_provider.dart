import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/session_manager.dart';
import 'database_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(databaseProvider));
});

class AuthNotifier extends StateNotifier<AppUser?> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(null);

  bool get isLoggedIn => state != null;
  bool get isAdmin => state?.role == UserRole.admin;
  bool get isWorker => state?.role == UserRole.worker;

  Future<bool> login(String pin) async {
    final user = await _repo.authenticateByPin(pin);
    state = user;
    if (user != null) {
      await SessionManager.saveSession(user.id);
    }
    return user != null;
  }

  Future<void> logout() async {
    state = null;
    await SessionManager.clearSession();
  }

  /// Try to restore session from saved preferences
  Future<bool> restoreSession() async {
    final userId = await SessionManager.getSession();
    if (userId == null) return false;

    final users = await _repo.getAllUsers();
    final match = users.where((u) => u.id == userId);
    if (match.isEmpty) {
      await SessionManager.clearSession();
      return false;
    }

    state = match.first;
    return true;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
