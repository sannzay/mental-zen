import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/reminder.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(
      settings,
    );
    const androidChannel = AndroidNotificationChannel(
      'mental_zen_channel',
      'Mental Zen',
      description: 'Wellness reminders',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    _initialized = true;
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    await init();
    final id = _idForReminder(reminder.id);
    await _plugin.show(
      id,
      reminder.title,
      reminder.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mental_zen_channel',
          'Mental Zen',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: reminder.id,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    await init();
    await _plugin.cancel(_idForReminder(reminderId));
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  int _idForReminder(String id) {
    return id.hashCode & 0x7fffffff;
  }
}


