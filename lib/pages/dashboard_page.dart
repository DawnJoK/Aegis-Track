import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/database_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time system overview and monitoring',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 32),

            // System Status Card
            const _SystemStatusCard(),
            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Active Alerts',
                    value: '0',
                    color: const Color(0xFFFF5252),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Resolved',
                    value: '0',
                    color: const Color(0xFF00E676),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.access_time,
                    label: 'Today',
                    value: '0',
                    color: const Color(0xFFFFB74D),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.camera_alt,
                    label: 'Evidence',
                    value: '0',
                    color: const Color(0xFF2979FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            _SectionCard(
              title: 'Recent Activity',
              action: TextButton(
                onPressed: () => context.go('/alerts'),
                child: const Text('View all →'),
              ),
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No alerts recorded',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: DatabaseService().settingsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStatusCard(context, false, error: true);
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = snapshot.data!;
        final bool systemArmed = settings['systemArmed'] ?? false;

        return _buildStatusCard(context, systemArmed);
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool systemArmed, {
    bool error = false,
  }) {
    final color = error
        ? Colors.red
        : (systemArmed ? const Color(0xFF00E676) : Colors.grey);
    final statusText = error
        ? 'CONNECTION ERROR'
        : (systemArmed ? 'SYSTEM SAFE' : 'SYSTEM OFFLINE');
    final subText = error
        ? 'Unable to connect to database'
        : (systemArmed
              ? 'All sensors nominal — No threats detected'
              : 'System is currently offline');
    final icon = error
        ? Icons.error_outline
        : (systemArmed ? Icons.verified_user : Icons.power_settings_new);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF05111A), // Dark greenish tint background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2338)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0A1F1C), Theme.of(context).cardColor],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subText,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2338)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _SectionCard({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            action ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2338)),
          ),
          child: child,
        ),
      ],
    );
  }
}
