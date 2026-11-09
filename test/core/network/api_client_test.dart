import 'dart:convert';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = TokenStorage(role: 'coach');
  });

  ApiClient build(
    MockClientHandler handler, {
    Duration timeout = const Duration(seconds: 5),
  }) => ApiClient(
    baseUrl: 'http://test/api/v1',
    tokenStorage: storage,
    logger: FakeLogger(),
    client: MockClient(handler),
    requestTimeout: timeout,
    retryDelay: Duration.zero,
  );

  test('unwraps data from the success envelope', () async {
    final client = build(
      (_) async => _json({
        'success': true,
        'data': {'a': 'سلام'},
      }, 200),
    );
    expect(await client.get('/x'), {'a': 'سلام'});
  });

  test('sends the bearer token when a session exists', () async {
    await storage.saveToken('abc');
    String? header;
    final client = build((req) async {
      header = req.headers['Authorization'];
      return _json({'success': true, 'data': null}, 200);
    });
    await client.get('/x');
    expect(header, 'Bearer abc');
  });

  test('422 keeps the first validation message', () async {
    final client = build(
      (_) async => _json({
        'success': false,
        'message': 'Validation failed',
        'errors': {
          'day': ['Day must be valid'],
        },
      }, 422),
    );

    try {
      await client.post('/x', {});
      fail('should throw');
    } on ApiException catch (e) {
      expect(e.statusCode, 422);
      final mapped = ApiException.mapApiException(e);
      expect(mapped, isA<ValidationException>());
      expect(mapped.message, 'Day must be valid');
    }
  });

  test(
    'non-JSON gateway response becomes ApiException, not FormatException',
    () async {
      final client = build(
        (_) async => http.Response('<html>Bad Gateway</html>', 502),
      );
      await expectLater(
        client.get('/x'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 502)),
      );
    },
  );

  test('401 notifies onUnauthorized', () async {
    var notified = false;
    final client = build(
      (_) async => _json({'success': false, 'message': 'x'}, 401),
    )..onUnauthorized = () => notified = true;
    await expectLater(client.get('/x'), throwsA(isA<ApiException>()));
    expect(notified, isTrue);
  });

  test('GET is retried once after a connection failure', () async {
    var calls = 0;
    final client = build((_) async {
      calls++;
      if (calls == 1) throw http.ClientException('offline');
      return _json({'success': true, 'data': 1}, 200);
    });
    expect(await client.get('/x'), 1);
    expect(calls, 2);
  });

  test('POST is never retried and maps to NetworkException', () async {
    var calls = 0;
    final client = build((_) async {
      calls++;
      throw http.ClientException('offline');
    });
    await expectLater(client.post('/x', {}), throwsA(isA<NetworkException>()));
    expect(calls, 1);
  });

  test('timeout maps to NetworkException (GET tried twice)', () async {
    var calls = 0;
    final client = build((_) async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _json({'success': true, 'data': null}, 200);
    }, timeout: const Duration(milliseconds: 30));
    await expectLater(client.get('/x'), throwsA(isA<NetworkException>()));
    expect(calls, 2);
  });
}
