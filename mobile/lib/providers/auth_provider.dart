import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final storageServiceProvider = Provider((ref) => StorageService());
final apiServiceProvider = Provider((ref) {
  return ApiService(ref.read(storageServiceProvider));
});
final authServiceProvider = Provider((ref) {
  return AuthService(ref.read(apiServiceProvider), ref.read(storageServiceProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(storageServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthNotifier(this._authService, this._storageService) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
        return;
      }

      final userJson = await _storageService.getUserJson();
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: User.fromJson(userMap),
        );
      }

      // Verify token in background without logging out user if network drops
      final user = await _authService.getMe();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else if (state.user == null) {
        // Only mark unauthenticated if we have no valid cached user
        await _authService.logout();
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    } catch (e) {
      if (state.user == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final user = await _authService.register(fullName, email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
    } else {
      state = state.copyWith(errorMessage: null);
    }
  }
}
