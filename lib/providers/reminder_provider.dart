import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  final NotificationService _notifications = NotificationService();
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
        _rescheduleAll();
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
      final withUser = reminder.copyWith(userId: _userId);
      await _firestore.createReminder(withUser);
      await _notifications.scheduleReminder(withUser);
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
      final withUser = reminder.copyWith(userId: _userId);
      await _firestore.updateReminder(withUser);
      if (withUser.isEnabled) {
        await _notifications.scheduleReminder(withUser);
      } else {
        await _notifications.cancelReminder(withUser.id);
      }
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
      await _notifications.cancelReminder(id);
    } catch (_) {
      errorMessage = 'Unable to delete reminder';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleReminder(Reminder reminder, bool enabled) {
    return updateReminder(reminder.copyWith(isEnabled: enabled));
  }

  Future<void> _rescheduleAll() async {
    await _notifications.cancelAll();
    for (final reminder in _reminders.where((r) => r.isEnabled)) {
      await _notifications.scheduleReminder(reminder);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


