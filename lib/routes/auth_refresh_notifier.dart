import 'dart:async';
import 'package:flutter/foundation.dart';
import '../blocs/auth_bloc.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  AuthRefreshNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((state) {
      if (state is AuthAuthenticated ||
          state is AuthInitial ||
          state is AuthRegistered) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
