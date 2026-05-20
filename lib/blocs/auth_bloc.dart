// AuthBloc - State Flow:
// AuthInitial -> AuthLoading -> AuthAuthenticated (login success)
// AuthInitial -> AuthLoading -> AuthError (login failure)
// AuthAuthenticated -> AuthInitial (logout)

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static final List<User> _registeredUsers = [
    const User(
      id: '1',
      name: 'Anisa Rahma',
      email: 'anisa@email.com',
      password: 'password123',
    ),
  ];

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    final inputEmail = event.email.trim().toLowerCase();
    final inputPassword = event.password.trim();

    debugPrint('=== LOGIN ATTEMPT ===');
    debugPrint('Input email: $inputEmail');
    debugPrint('Input password: $inputPassword');
    debugPrint('Total registered users: ${_registeredUsers.length}');
    for (final u in _registeredUsers) {
      debugPrint('  Stored: ${u.email} / ${u.password}');
    }

    User? matchedUser;
    for (final user in _registeredUsers) {
      if (user.email.trim().toLowerCase() == inputEmail &&
          user.password == inputPassword) {
        matchedUser = user;
        break;
      }
    }

    debugPrint('Match found: ${matchedUser != null}');
    debugPrint('====================');

    if (matchedUser != null) {
      emit(AuthAuthenticated(user: matchedUser));
    } else {
      final emailExists = _registeredUsers.any(
        (user) => user.email.trim().toLowerCase() == inputEmail,
      );
      if (emailExists) {
        emit(const AuthError(message: 'Password salah. Silakan coba lagi.'));
      } else {
        emit(const AuthError(message: 'Email tidak terdaftar. Silakan daftar akun.'));
      }
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));

    final trimmedName = event.name.trim();
    final trimmedEmail = event.email.trim().toLowerCase();
    final trimmedPassword = event.password.trim();

    if (trimmedName.length < 2) {
      emit(const AuthError(message: 'Nama minimal 2 karakter'));
      return;
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      emit(const AuthError(message: 'Format email tidak valid'));
      return;
    }
    if (trimmedPassword.length < 6) {
      emit(const AuthError(message: 'Password minimal 6 karakter'));
      return;
    }

    final emailExists = _registeredUsers.any(
      (u) => u.email.trim().toLowerCase() == trimmedEmail,
    );
    if (emailExists) {
      emit(const AuthError(message: 'Email sudah terdaftar. Silakan gunakan email lain.'));
      return;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmedName,
      email: trimmedEmail,
      password: trimmedPassword,
    );

    _registeredUsers.add(newUser);

    debugPrint('=== REGISTERED USERS ===');
    for (final u in _registeredUsers) {
      debugPrint('  ${u.email} / ${u.password}');
    }
    debugPrint('========================');

    emit(AuthRegistered(user: newUser));

    await Future.delayed(const Duration(milliseconds: 200));
    emit(AuthInitial());
  }
}
