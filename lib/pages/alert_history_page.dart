import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class AlertHistoryPage extends StatefulWidget {
  const AlertHistoryPage({super.key});

  @override
  State<AlertHistoryPage> createState() => _AlertHistoryPageState();
}

class _AlertHistoryPageState extends State<AlertHistoryPage> {
  String _selectedType = 'All Types';
  String _selectedStatus = 'All Status';
  String _selectedSort = 'Newest';
  String _selectedProduct = 'All';

  final List<String> _typeOptions = [
    'All Types',
    'Movement',
    'Vibration',
    'Tamper',
  ];

  final List<String> _statusOptions = [
    'All Status',
    'Active',
    'Resolved',
    'False Alarm',
  ];

  final List<String> _sortOptions = ['Newest', 'Oldest'];

  final List<String> _productOptions = [
    'All',
    'Bike',
    'Car',
    'Bag',
    'Locker',
    'Scooter',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert History',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete log of all security incidents',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),

            const SizedBox(height: 32),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 20, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text('Filter:', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(width: 16),
                  _FilterDropdown(
                    value: _selectedProduct,
                    items: _productOptions,
                    onChanged: (val) => setState(() => _selectedProduct = val!),
                    icon: Icons.devices_other,
                  ),
                  const SizedBox(width: 12),
                  _FilterDropdown(
                    value: _selectedType,
                    items: _typeOptions,
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(width: 12),
                  _FilterDropdown(
                    value: _selectedStatus,
                    items: _statusOptions,
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                  const SizedBox(width: 12),
                  _FilterDropdown(
                    value: _selectedSort,
                    items: _sortOptions,
                    onChanged: (val) => setState(() => _selectedSort = val!),
                    icon: Icons.swap_vert,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Table Header and Body
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2338)),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          const _HeaderCell('Date & Time', flex: 2),
                          const _HeaderCell('Product', flex: 1),
                          const _HeaderCell('Type', flex: 2),
                          const _HeaderCell('Location', flex: 2),
                          const _HeaderCell('Status', flex: 1),
                          const _HeaderCell('Evidence', flex: 1),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1E2338)),

                    // Alerts List
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: DatabaseService().alertsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final allDocs = snapshot.data ?? [];

                          // Apply local filters
                          final docs = allDocs.where((data) {
                            // Type Filter
                            if (_selectedType != 'All Types' &&
                                data['type'] != _selectedType) {
                              return false;
                            }

                            // Status Filter
                            if (_selectedStatus != 'All Status' &&
                                data['status'] != _selectedStatus) {
                              return false;
                            }

                            // Product Filter
                            if (_selectedProduct != 'All') {
                              if (data['product'] != _selectedProduct) {
                                return false;
                              }
                            }

                            return true;
                          }).toList();

                          if (docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No alerts found',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(0),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFF1E2338),
                            ),
                            itemBuilder: (context, index) {
                              final data = docs[index];
                              // Handle timestamp conversion safely
                              final timestamp = data['timestamp'];
                              String timeStr = 'Unknown';
                              if (timestamp is Timestamp) {
                                final dt = timestamp.toDate();
                                timeStr =
                                    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                                // Simplified date for now
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        timeStr,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        data['product'] ?? 'N/A',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconForType(data['type']),
                                            size: 16,
                                            color: _getColorForType(
                                              data['type'],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            data['type'] ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        data['location'] ?? 'N/A',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        data['status'] ?? 'Active',
                                        style: TextStyle(
                                          color: data['status'] == 'Resolved'
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.image,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ), // Placeholder for evidence link
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFF1E2338)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'Movement':
        return Icons.directions_run;
      case 'Vibration':
        return Icons.vibration;
      case 'Tamper':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'Movement':
        return Colors.blue;
      case 'Vibration':
        return Colors.orange;
      case 'Tamper':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1429),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E2338)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Colors.grey,
          ),
          dropdownColor: const Color(0xFF0F1429),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (icon != null && item == value) ...[
                    Icon(icon, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
