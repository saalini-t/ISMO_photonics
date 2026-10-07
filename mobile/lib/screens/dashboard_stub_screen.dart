import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class DashboardStubScreen extends ConsumerWidget {
  const DashboardStubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user?.fullName ?? 'User'}!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/projects'),
              child: const Text('Go to Projects'),
            )
          ],
        ),
      ),
    );
  }
}
