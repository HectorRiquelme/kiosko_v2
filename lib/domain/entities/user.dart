enum UserRole { admin, worker }

class AppUser {
  final String id;
  final String name;
  final String pin;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.pin,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
