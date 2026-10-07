import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_stub_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isAuthenticating = authState.status == AuthStatus.authenticating;
      final isInitial = authState.status == AuthStatus.initial;
      
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';

      if (isInitial || isAuthenticating) {
        return null; // Stay on current screen while loading
      }

      if (!isAuth && !isLogin && !isRegister) {
        return '/login';
      }

      if (isAuth && (isLogin || isRegister)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardStubScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Projects Stub'))),
      ),
    ],
  );
});
