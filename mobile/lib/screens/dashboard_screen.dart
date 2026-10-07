import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/dashboard_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsyncValue = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile action
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout action
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: dashboardAsyncValue.when(
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard('Total Projects', stats.totalProjects.toString(), Colors.blue),
                    _buildStatCard('In Progress Projects', stats.projectsInProgress.toString(), Colors.orange),
                    _buildStatCard('Total Tasks', stats.totalTasks.toString(), Colors.purple),
                    _buildStatCard('Pending Tasks', stats.pendingTasks.toString(), Colors.red),
                    _buildStatCard('Completed Tasks', stats.completedTasks.toString(), Colors.green),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Quick Links', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: Colors.indigo),
                    title: const Text('View Projects'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/projects'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.task, color: Colors.indigo),
                    title: const Text('View Tasks'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/tasks'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
