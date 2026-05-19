// AuthBloc - State Flow:
// AuthInitial -> AuthLoading -> AuthAuthenticated (login success)
// AuthInitial -> AuthLoading -> AuthError (login failure)
// AuthAuthenticated -> AuthInitial (logout)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../data/dummy_data.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));

    final user = DummyData.currentUser;
    if (event.email == user.email && event.password == user.password) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthError(message: 'Email atau password salah'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
