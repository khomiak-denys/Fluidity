import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_setting.dart';

/// Repository for reminder settings
///
/// Data model layout (assumption):
/// - Collection: users
///   - Doc: <userId>
///     - Subcollection: reminders
///       - Doc: <reminderId>
///         - Fields: scheduledTime (ISO8601 string), comment, isActive
class ReminderSettingRepository {
  ReminderSettingRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const String _colUsers = 'users';
  static const String _subcolReminders = 'reminders';

  CollectionReference<Map<String, dynamic>> _remindersCol(String userId) =>
      _db.collection(_colUsers).doc(userId).collection(_subcolReminders);

  /// Stream all reminders ordered by scheduledTime ascending
  Stream<List<ReminderSetting>> watchAll(String userId) {
    return _remindersCol(userId)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ReminderSetting.fromMap(d.data(), d.id))
            .toList());
  }

  Future<List<ReminderSetting>> fetchAll(String userId) async {
    final q = await _remindersCol(userId).orderBy('scheduledTime').get();
    return q.docs.map((d) => ReminderSetting.fromMap(d.data(), d.id)).toList();
  }

  Future<void> add(String userId, ReminderSetting r) async {
    await _remindersCol(userId).doc(r.id).set(r.toMap());
  }

  Future<void> update(String userId, ReminderSetting r) async {
    await _remindersCol(userId).doc(r.id).set(r.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String userId, String id) async {
    await _remindersCol(userId).doc(id).delete();
  }
}
