import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/journal_entry.dart';
import '../models/mood_entry.dart';
import '../models/reminder.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCollection(String userId) {
    return _db.collection('users').doc(userId).collection('_root').parent as CollectionReference<Map<String, dynamic>>;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _db.collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _moodCollection(String userId) {
    return _userDoc(userId).collection('mood_entries');
  }

  CollectionReference<Map<String, dynamic>> _journalCollection(String userId) {
    return _userDoc(userId).collection('journal_entries');
  }

  CollectionReference<Map<String, dynamic>> _reminderCollection(String userId) {
    return _userDoc(userId).collection('reminders');
  }

  Future<void> upsertUser(UserModel user) {
    return _userDoc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Stream<UserModel?> userStream(String userId) {
    return _userDoc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data()!;
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      return UserModel.fromJson(
        snapshot.id,
        {
          ...data,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        },
      );
    });
  }

  Future<void> createMoodEntry(MoodEntry entry) {
    final ref = _moodCollection(entry.userId).doc(entry.id);
    return ref.set(entry.toJson());
  }

  Future<void> updateMoodEntry(MoodEntry entry) {
    final ref = _moodCollection(entry.userId).doc(entry.id);
    return ref.update(entry.toJson());
  }

  Future<void> deleteMoodEntry(String userId, String id) {
    return _moodCollection(userId).doc(id).delete();
  }

  Stream<List<MoodEntry>> moodEntriesStream(String userId) {
    return _moodCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapMoodDoc).toList());
  }

  Future<List<MoodEntry>> moodEntriesInRange(String userId, DateTime start, DateTime end) async {
    final query = await _moodCollection(userId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map(_mapMoodDoc).toList();
  }

  MoodEntry _mapMoodDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return MoodEntry.fromJson(
      doc.id,
      {
        ...data,
        'createdAt': createdAt,
      },
    );
  }

  Future<void> createJournalEntry(JournalEntry entry) {
    final ref = _journalCollection(entry.userId).doc(entry.id);
    return ref.set(entry.toJson());
  }

  Future<void> updateJournalEntry(JournalEntry entry) {
    final ref = _journalCollection(entry.userId).doc(entry.id);
    return ref.update(entry.toJson());
  }

  Future<void> deleteJournalEntry(String userId, String id) {
    return _journalCollection(userId).doc(id).delete();
  }

  Stream<List<JournalEntry>> journalEntriesStream(String userId) {
    return _journalCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapJournalDoc).toList());
  }

  Future<List<JournalEntry>> journalEntriesInRange(String userId, DateTime start, DateTime end) async {
    final query = await _journalCollection(userId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map(_mapJournalDoc).toList();
  }

  JournalEntry _mapJournalDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt;
    return JournalEntry.fromJson(
      doc.id,
      {
        ...data,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      },
    );
  }

  Future<void> createReminder(Reminder reminder) {
    final ref = _reminderCollection(reminder.userId).doc(reminder.id);
    return ref.set(reminder.toJson());
  }

  Future<void> updateReminder(Reminder reminder) {
    final ref = _reminderCollection(reminder.userId).doc(reminder.id);
    return ref.update(reminder.toJson());
  }

  Future<void> deleteReminder(String userId, String id) {
    return _reminderCollection(userId).doc(id).delete();
  }

  Stream<List<Reminder>> remindersStream(String userId) {
    return _reminderCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapReminderDoc).toList());
  }

  Reminder _mapReminderDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Reminder.fromJson(
      doc.id,
      {
        ...data,
        'createdAt': createdAt,
      },
    );
  }
}


