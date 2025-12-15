import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../services/firestore_service.dart';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _userId;
  final List<Reminder> _reminders = [];
  bool isLoading = false;
  String? errorMessage;
  StreamSubscription<List<Reminder>>? _subscription;

  ReminderProvider(this._firestore);

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  void setUser(String? userId) {
    if (_userId == userId) {
      return;
    }
    _userId = userId;
    _subscription?.cancel();
    _reminders.clear();
    if (userId == null) {
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    _subscription = _firestore.remindersStream(userId).listen(
      (data) {
        _reminders
          ..clear()
          ..addAll(data);
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Unable to load reminders';
        notifyListeners();
      },
    );
  }

  Future<void> addReminder(Reminder reminder) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _firestore.createReminder(reminder);
    } catch (_) {
      errorMessage = 'Unable to save reminder';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _firestore.updateReminder(reminder);
    } catch (_) {
      errorMessage = 'Unable to update reminder';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    if (_userId == null) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _firestore.deleteReminder(_userId!, id);
    } catch (_) {
      errorMessage = 'Unable to delete reminder';
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


