import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/database_service.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarHidden = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleNavTap(String route) {
    if (MediaQuery.of(context).size.width < 800) {
      // In mobile, close the drawer safely using the scaffold key
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      // On desktop, user asked "the sidebar should go in hidden mode as well"
      if (!_isSidebarHidden) {
        setState(() {
          _isSidebarHidden = true;
        });
      }
    }
    context.go(route);
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                  ),
                  if (MediaQuery.of(context).size.width >= 800)
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _isSidebarHidden = true;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Navigation Items
          _NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/',
            onTap: () => _handleNavTap('/'),
          ),
          _NavItem(
            icon: Icons.map,
            label: 'Live Map',
            route: '/map',
            onTap: () => _handleNavTap('/map'),
          ),
          _NavItem(
            icon: Icons.image,
            label: 'Evidence',
            route: '/evidence',
            onTap: () => _handleNavTap('/evidence'),
          ),
          _NavItem(
            icon: Icons.history,
            label: 'Alert History',
            route: '/alerts',
            onTap: () => _handleNavTap('/alerts'),
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.settings,
            label: 'Settings',
            route: '/settings',
            onTap: () => _handleNavTap('/settings'),
          ),

          // System Status
          SafeArea(
            top: false,
            child: StreamBuilder<Map<String, dynamic>>(
              stream: DatabaseService().settingsStream,
              builder: (context, snapshot) {
                final bool systemArmed =
                    snapshot.hasData &&
                    (snapshot.data!['systemArmed'] ?? false);
                final color = systemArmed
                    ? const Color(0xFF00E676)
                    : Colors.red;
                final text = systemArmed ? 'System Online' : 'System Offline';

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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey, // Add GlobalKey here for easy closing
        appBar: AppBar(
          title: Text(
            'AEGIS TRACK',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        drawer: Drawer(child: _buildSidebar(context)),
        body: widget.child,
      );
    }

    return Scaffold(
      appBar: _isSidebarHidden
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    _isSidebarHidden = false;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar
          if (!_isSidebarHidden) _buildSidebar(context),

          // Main Content
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.onTap,
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
          onTap: onTap,
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
