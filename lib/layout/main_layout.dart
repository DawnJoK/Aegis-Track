import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/database_service.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Area
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AEGIS TRACK',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          Text(
                            'SECURITY SYSTEM',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation Items
                _NavItem(icon: Icons.dashboard, label: 'Dashboard', route: '/'),
                _NavItem(icon: Icons.map, label: 'Live Map', route: '/map'),
                _NavItem(
                  icon: Icons.image,
                  label: 'Evidence',
                  route: '/evidence',
                ),
                _NavItem(
                  icon: Icons.history,
                  label: 'Alert History',
                  route: '/alerts',
                ),
                const Spacer(),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  route: '/settings',
                ),

                // System Status
                // System Status
                StreamBuilder<Map<String, dynamic>>(
                  stream: DatabaseService().settingsStream,
                  builder: (context, snapshot) {
                    final bool systemArmed =
                        snapshot.hasData &&
                        (snapshot.data!['systemArmed'] ?? false);
                    final color = systemArmed
                        ? const Color(0xFF00E676)
                        : Colors.red;
                    final text = systemArmed
                        ? 'System Online'
                        : 'System Offline';

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            text,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final bool isSelected = state.uri.toString() == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border(
                      left: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
