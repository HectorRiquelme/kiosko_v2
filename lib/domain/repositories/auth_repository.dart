import '../entities/user.dart';

abstract class AuthRepository {
  Future<AppUser?> authenticateByPin(String pin);
  Future<List<AppUser>> getAllUsers();
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<void> deleteUser(String id);
}
