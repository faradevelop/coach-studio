import 'dart:async';
import 'package:flutter/foundation.dart';

/// Bridges a Bloc/Cubit's state [Stream] into a [Listenable] so `go_router`
/// re-evaluates its `redirect` callback whenever `AuthCubit`'s state
/// changes (login, logout, session restore, forced sign-out on 401, etc).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
