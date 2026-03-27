import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _firmwareController = TextEditingController();
  bool _isLoaded = false;

  @override
  void dispose() {
    _deviceNameController.dispose();
    _firmwareController.dispose();
    super.dispose();
  }

  void _saveTextSettings() {
    DatabaseService().updateSettings({
      'deviceName': _deviceNameController.text,
      'firmwareVersion': _firmwareController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<String, dynamic>>(
        stream: DatabaseService().settingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = snapshot.data!;

          // Populate controllers once when data is available
          if (!_isLoaded) {
            _deviceNameController.text = settings['deviceName'] ?? '';
            _firmwareController.text = settings['firmwareVersion'] ?? '';
            _isLoaded = true;
          }

          final bool systemArmed = settings['systemArmed'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  systemArmed
                      ? 'System is ARMED and monitoring'
                      : 'System is currently OFFLINE',
                  style: TextStyle(
                    fontSize: 14,
                    color: systemArmed
                        ? const Color(0xFF00E676)
                        : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 32),

                // Device Configuration
                _SectionContainer(
                  icon: Icons.smartphone,
                  title: 'Device Configuration',
                  subtitle: 'Basic device settings',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Device Name'),
                      const SizedBox(height: 8),
                      _DarkInput(
                        hint: 'e.g., Vehicle Tracker 01',
                        controller: _deviceNameController,
                      ),
                      const SizedBox(height: 16),
                      const _Label('Firmware Version'),
                      const SizedBox(height: 8),
                      _DarkInput(
                        hint: 'e.g., v1.2.0',
                        controller: _firmwareController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Security
                _SectionContainer(
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Arm/disarm your security system',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'System Armed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'When armed, the device will trigger alerts on detected threats',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: systemArmed,
                        onChanged: (value) {
                          DatabaseService().updateSettings({
                            'systemArmed': value,
                          });
                        },
                        activeThumbColor: const Color(0xFF00E676),
                        activeTrackColor: const Color(
                          0xFF00E676,
                        ).withValues(alpha: 0.2),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications
                _SectionContainer(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Configure alert preferences',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1429),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E2338)),
                    ),
                    child: Center(
                      child: Text(
                        'Notification settings will be available in a future update.\nCurrently, all alerts are logged in the Alert History.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _saveTextSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676), // Green
                      foregroundColor: const Color(0xFF05081C), // Dark text
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.save, size: 20),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await AuthService().signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Footer
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: systemArmed
                            ? const Color(0xFF00E676)
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      systemArmed ? 'System Online' : 'System Offline',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionContainer({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2338)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2338),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF00E676)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 13));
  }
}

class _DarkInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;

  const _DarkInput({required this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0F1429),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E2338)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E2338)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00E676)),
        ),
      ),
    );
  }
}
