/// Mirrors the Backend's `users.role` column exactly (`'admin' | 'coach'`,
/// see `User::isAdmin()` / `User::isCoach()`). No other roles exist.
enum UserRole {
  admin,
  coach;

  String get label {
    return switch (this) {
      UserRole.admin => 'مدیر',
      UserRole.coach => 'مربی',
    };
  }
}
