import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class EvidencePage extends StatelessWidget {
  const EvidencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evidence Gallery',
              style: TextStyle(
                fontSize: 28, // Matches dashboard header
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Images captured by ESP32-CAM during security events',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DatabaseService().evidenceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2338),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No evidence captured yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Images will appear here when the ESP32-CAM captures security events',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      final imageUrl = data['imageUrl'] as String?;
                      final timestamp = data['timestamp'];

                      String timeStr = 'Unknown';
                      if (timestamp is Timestamp) {
                        final dt = timestamp.toDate();
                        timeStr =
                            '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1429),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E2338)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              Container(
                                color: const Color(0xFF1E2338),
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),

                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black54,
                                child: Text(
                                  timeStr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
