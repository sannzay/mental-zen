import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import '../services/firestore_service.dart';

class MoodProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _userId;
  final List<MoodEntry> _entries = [];
  bool isLoading = false;
  String? errorMessage;
  DateTimeRange? filterRange;
  StreamSubscription<List<MoodEntry>>? _subscription;

  MoodProvider(this._firestore);

  List<MoodEntry> get entries {
    if (filterRange == null) {
      return List.unmodifiable(_entries);
    }
    final start = filterRange!.start;
    final end = filterRange!.end;
    return _entries
        .where(
          (e) => !e.createdAt.isBefore(start) && !e.createdAt.isAfter(end),
        )
        .toList();
  }

  MoodEntry? get todaysMood {
    final now = DateTime.now();
    for (final entry in _entries) {
      if (_isSameDay(entry.createdAt, now)) {
        return entry;
      }
    }
    return null;
  }

  double? get weeklyAverage {
    if (_entries.isEmpty) {
      return null;
    }
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final recent = _entries.where(
      (e) => !e.createdAt.isBefore(DateTime(start.year, start.month, start.day)) &&
          !e.createdAt.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59)),
    );
    final list = recent.toList();
    if (list.isEmpty) {
      return null;
    }
    final sum = list.fold<int>(0, (acc, e) => acc + e.moodScore);
    return sum / list.length;
  }

  void setUser(String? userId) {
    if (_userId == userId) {
      return;
    }
    _userId = userId;
    _subscription?.cancel();
    _entries.clear();
    if (userId == null) {
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    _subscription = _firestore.moodEntriesStream(userId).listen(
      (data) {
        _entries
          ..clear()
          ..addAll(data);
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Unable to load mood entries';
        notifyListeners();
      },
    );
  }

  void setFilter(DateTimeRange? range) {
    filterRange = range;
    notifyListeners();
  }

  Future<void> addMood(MoodEntry entry) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final userId = _userId;
      if (userId == null) {
        return;
      }
      final withUser = entry.copyWith(userId: userId);
      _entries.insert(0, withUser);
      notifyListeners();
      await _firestore.createMoodEntry(withUser);
    } catch (_) {
      errorMessage = 'Unable to save mood';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMood(MoodEntry entry) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final userId = _userId;
      if (userId == null) {
        return;
      }
      final withUser = entry.copyWith(userId: userId);
      final index = _entries.indexWhere((e) => e.id == withUser.id);
      if (index != -1) {
        _entries[index] = withUser;
      }
      notifyListeners();
      await _firestore.updateMoodEntry(withUser);
    } catch (_) {
      errorMessage = 'Unable to update mood';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMood(String id) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      await _firestore.deleteMoodEntry(_userId!, id);
    } catch (_) {
      errorMessage = 'Unable to delete mood';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


