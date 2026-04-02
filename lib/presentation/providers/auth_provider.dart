import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
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
    return user != null;
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
