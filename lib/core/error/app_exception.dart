abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

/// Thrown when the Backend responds 401 — the request had no token, or the
/// token is missing/invalid/expired/revoked (e.g. after logout, or after a
/// password change/reset which revokes ALL of the user's Sanctum tokens).
class UnauthenticatedException extends AppException {
  const UnauthenticatedException(super.message);
}

/// Thrown when the Backend responds 403 — the user is authenticated but
/// the relevant Policy denies the action (e.g. a non-admin trying to
/// mutate a resource that isn't theirs, if it were ever exposed as 403
/// rather than scoped to 404 as the current controllers do).
class ForbiddenException extends AppException {
  const ForbiddenException(super.message);
}
