import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_session.dart';
import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository repo;
  late TokenStorage storage;
  late AuthCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = FakeAuthRepository();
    storage = TokenStorage(role: 'coach');
    cubit = AuthCubit(
      repository: repo,
      tokenStorage: storage,
      allowedRole: UserRole.coach,
      logger: FakeLogger(),
    );
  });

  tearDown(() => cubit.close());

  test('success stores the token and authenticates', () async {
    repo.onLogin = (_, _) async =>
        AuthSession(user: userFixture(), token: 'tok');

    expect(await cubit.login('coach1', 'pw'), LoginOutcome.success);
    expect(cubit.state, isA<AuthAuthenticated>());
    expect(storage.token, 'tok');
  });

  test('network failure is reported as network, not wrong password', () async {
    repo.onLogin = (_, _) async => throw const NetworkException('offline');

    expect(await cubit.login('a', 'b'), LoginOutcome.network);
    expect(cubit.state, isA<AuthUnauthenticated>());
  });

  test('422 means invalid credentials', () async {
    repo.onLogin = (_, _) async => throw const ValidationException('bad');
    expect(await cubit.login('a', 'b'), LoginOutcome.invalidCredentials);
  });

  test('429 means too many attempts', () async {
    repo.onLogin = (_, _) async => throw const RateLimitException('slow down');
    expect(await cubit.login('a', 'b'), LoginOutcome.tooManyAttempts);
  });

  test('unexpected error means server error', () async {
    repo.onLogin = (_, _) async => throw StateError('boom');
    expect(await cubit.login('a', 'b'), LoginOutcome.serverError);
  });

  test(
    'account of another app role is rejected and its token revoked',
    () async {
      repo.onLogin = (_, _) async => AuthSession(
        user: userFixture(role: UserRole.admin),
        token: 'tok',
      );

      expect(await cubit.login('admin', 'pw'), LoginOutcome.invalidCredentials);
      expect(cubit.state, isA<AuthUnauthenticated>());
      expect(storage.token, isNull);
      expect(repo.logoutCalls, 1);
    },
  );
}
