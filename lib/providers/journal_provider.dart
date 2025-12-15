import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../services/firestore_service.dart';

class JournalProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _userId;
  final List<JournalEntry> _entries = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  bool favoritesOnly = false;
  bool recentOnly = false;
  List<String> tagFilter = [];
  DateTimeRange? dateFilter;
  StreamSubscription<List<JournalEntry>>? _subscription;

  JournalProvider(this._firestore);

  List<JournalEntry> get entries {
    Iterable<JournalEntry> list = _entries;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where(
        (e) => e.title.toLowerCase().contains(q) || e.content.toLowerCase().contains(q),
      );
    }
    if (favoritesOnly) {
      list = list.where((e) => e.isFavorite);
    }
    if (recentOnly) {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));
      list = list.where(
        (e) => !e.createdAt.isBefore(start),
      );
    }
    if (tagFilter.isNotEmpty) {
      list = list.where(
        (e) => e.tags.any(tagFilter.contains),
      );
    }
    if (dateFilter != null) {
      final start = dateFilter!.start;
      final end = dateFilter!.end;
      list = list.where(
        (e) => !e.createdAt.isBefore(start) && !e.createdAt.isAfter(end),
      );
    }
    return list.toList()
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
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
    _subscription = _firestore.journalEntriesStream(userId).listen(
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
        errorMessage = 'Unable to load journal entries';
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    favoritesOnly = value;
    notifyListeners();
  }

  void setRecentOnly(bool value) {
    recentOnly = value;
    notifyListeners();
  }

  void setTagFilter(List<String> tags) {
    tagFilter = tags;
    notifyListeners();
  }

  void setDateFilter(DateTimeRange? range) {
    dateFilter = range;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
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
      await _firestore.createJournalEntry(withUser);
    } catch (_) {
      errorMessage = 'Unable to save entry';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEntry(JournalEntry entry) async {
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
      await _firestore.updateJournalEntry(withUser);
    } catch (_) {
      errorMessage = 'Unable to update entry';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      await _firestore.deleteJournalEntry(_userId!, id);
    } catch (_) {
      errorMessage = 'Unable to delete entry';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


