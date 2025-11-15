import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_entry.dart';

/// Repository for water intake entries
///
/// Data model layout (assumption):
/// - Collection: users
///   - Doc: <userId>
///     - Subcollection: water_entries
///       - Doc: <entryId>
///         - Fields: amountMl, timestamp, drinkType, comment
class WaterEntryRepository {
  WaterEntryRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const String _colUsers = 'users';
  static const String _subcolEntries = 'water_entries';

  CollectionReference<Map<String, dynamic>> _entriesCol(String userId) =>
      _db.collection(_colUsers).doc(userId).collection(_subcolEntries);

  /// Stream all entries for a user, ordered by timestamp desc
  Stream<List<WaterEntry>> watchAll(String userId) {
    return _entriesCol(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WaterEntry.fromMap(d.data(), d.id))
            .toList());
  }

  /// Fetch all entries once
  Future<List<WaterEntry>> fetchAll(String userId) async {
    final q = await _entriesCol(userId).orderBy('timestamp', descending: true).get();
    return q.docs.map((d) => WaterEntry.fromMap(d.data(), d.id)).toList();
  }

  /// Fetch entries for a specific day (00:00 - 23:59)
  Future<List<WaterEntry>> fetchForDay(String userId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final q = await _entriesCol(userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .get();
    return q.docs.map((d) => WaterEntry.fromMap(d.data(), d.id)).toList();
  }

  Future<void> add(String userId, WaterEntry entry) async {
    await _entriesCol(userId).doc(entry.id).set(entry.toMap());
  }

  Future<void> update(String userId, WaterEntry entry) async {
    await _entriesCol(userId).doc(entry.id).set(entry.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String userId, String entryId) async {
    await _entriesCol(userId).doc(entryId).delete();
  }
}
