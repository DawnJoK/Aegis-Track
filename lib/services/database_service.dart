import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Helper to safely access Firestore
  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  // Streams
  Stream<List<Map<String, dynamic>>> get alertsStream {
    if (_db == null) {
      return Stream.error(
        'Firebase not initialized.\nPlease run "flutterfire configure" to connect.',
      );
    }
    return _db!
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Map<String, dynamic>> get newAlertsStream {
    if (_db == null) {
      return const Stream.empty();
    }
    // Only yield documents that are newly added after listening starts,
    // avoiding the initial state load.
    return _db!
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .limit(1) // Keep the query light, just looking for newest
        .snapshots()
        .skip(1) // Skip the first snapshot which contains existing data
        .expand((snapshot) {
      return snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.added)
          .map((change) => change.doc.data() ?? {});
    });
  }

  Stream<List<Map<String, dynamic>>> get evidenceStream {
    if (_db == null) {
      return Stream.error(
        'Firebase not initialized.\nPlease run "flutterfire configure" to connect.',
      );
    }
    return _db!
        .collection('evidence')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Map<String, dynamic>> get settingsStream {
    if (_db == null) {
      return Stream.error(
        'Firebase not initialized.\nPlease run "flutterfire configure" to connect.',
      );
    }
    return _db!
        .collection('settings')
        .doc('main_config')
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // Methods
  Future<void> addAlert(Map<String, dynamic> alertData) async {
    if (_db == null) return;
    await _db!.collection('alerts').add(alertData);
  }

  Future<void> addEvidence(Map<String, dynamic> evidenceData) async {
    if (_db == null) return;
    await _db!.collection('evidence').add(evidenceData);
  }

  Future<void> updateSettings(Map<String, dynamic> settingsData) async {
    if (_db == null) return;
    // detailed merge is true by default for set with SetOptions(merge: true)
    // but here we can just update specific fields
    await _db!
        .collection('settings')
        .doc('main_config')
        .set(settingsData, SetOptions(merge: true));
  }
}
