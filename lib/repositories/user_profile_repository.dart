import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Repository for reading/writing the current user's profile in Firestore.
///
/// Data model layout (assumption):
/// - Collection: users
///   - Doc: <userId>
///     - Fields: firstName, lastName, email, targetWaterAmount, registrationDate
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const String _colUsers = 'users';

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _db.collection(_colUsers).doc(userId);

  Future<UserProfile?> getById(String userId) async {
    final doc = await _userDoc(userId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserProfile.fromMap(data, doc.id);
  }

  Stream<UserProfile?> watchById(String userId) {
    return _userDoc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return UserProfile.fromMap(data, doc.id);
    });
  }

  Future<void> upsert(UserProfile profile) async {
    await _userDoc(profile.id).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> updateGoal(String userId, int targetWaterAmount) async {
    await _userDoc(userId).set({'targetWaterAmount': targetWaterAmount}, SetOptions(merge: true));
  }
}
