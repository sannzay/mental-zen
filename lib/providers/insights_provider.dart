import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../models/mood_entry.dart';
import 'journal_provider.dart';
import 'mood_provider.dart';

enum InsightsPeriod {
  week,
  month,
  year,
}

class InsightsProvider extends ChangeNotifier {
  final MoodProvider moodProvider;
  final JournalProvider journalProvider;

  InsightsPeriod period = InsightsPeriod.week;

  InsightsProvider({
    required this.moodProvider,
    required this.journalProvider,
  });

  List<MoodEntry> get moodEntriesInPeriod {
    final now = DateTime.now();
    DateTime start;
    if (period == InsightsPeriod.week) {
      start = now.subtract(const Duration(days: 6));
    } else if (period == InsightsPeriod.month) {
      start = DateTime(now.year, now.month - 1, now.day);
    } else {
      start = DateTime(now.year - 1, now.month, now.day);
    }
    return moodProvider.entries.where((e) => !e.createdAt.isBefore(start) && !e.createdAt.isAfter(now)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<JournalEntry> get journalEntriesInPeriod {
    final now = DateTime.now();
    DateTime start;
    if (period == InsightsPeriod.week) {
      start = now.subtract(const Duration(days: 6));
    } else if (period == InsightsPeriod.month) {
      start = DateTime(now.year, now.month - 1, now.day);
    } else {
      start = DateTime(now.year - 1, now.month, now.day);
    }
    return journalProvider.entries.where((e) => !e.createdAt.isBefore(start) && !e.createdAt.isAfter(now)).toList();
  }

  double? get averageMood {
    final list = moodEntriesInPeriod;
    if (list.isEmpty) {
      return null;
    }
    final sum = list.fold<int>(0, (acc, e) => acc + e.moodScore);
    return sum / list.length;
  }

  Map<int, int> get moodDistribution {
    final counts = <int, int>{1: 0, 2: 0, 3: 0};
    for (final entry in moodEntriesInPeriod) {
      if (entry.moodScore <= 3) {
        counts[1] = (counts[1] ?? 0) + 1;
      } else if (entry.moodScore <= 6) {
        counts[2] = (counts[2] ?? 0) + 1;
      } else {
        counts[3] = (counts[3] ?? 0) + 1;
      }
    }
    return counts;
  }

  int get currentStreak {
    return _streakFromEntries(moodProvider.entries);
  }

  String? get bestDayOfWeek {
    final list = moodEntriesInPeriod;
    if (list.isEmpty) {
      return null;
    }
    final sums = List<double>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (final entry in list) {
      final index = entry.createdAt.weekday % 7;
      sums[index] += entry.moodScore.toDouble();
      counts[index] += 1;
    }
    double bestAvg = -1;
    int bestIndex = -1;
    for (int i = 0; i < 7; i++) {
      if (counts[i] == 0) {
        continue;
      }
      final avg = sums[i] / counts[i];
      if (avg > bestAvg) {
        bestAvg = avg;
        bestIndex = i;
      }
    }
    if (bestIndex == -1) {
      return null;
    }
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[bestIndex];
  }

  int get journalingDaysCount {
    final days = <DateTime>{};
    for (final entry in journalEntriesInPeriod) {
      days.add(DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day));
    }
    return days.length;
  }

  Map<DateTime, int> get journalingActivityByDay {
    final map = <DateTime, int>{};
    for (final entry in journalEntriesInPeriod) {
      final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      map[day] = (map[day] ?? 0) + 1;
    }
    return map;
  }

  String? get bestDayInsight {
    final day = bestDayOfWeek;
    if (day == null) {
      return null;
    }
    return 'You tend to feel best on $day.';
  }

  String? get improvementInsight {
    if (period != InsightsPeriod.week) {
      return null;
    }
    final now = DateTime.now();
    final thisWeekStart = now.subtract(const Duration(days: 6));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisWeekEntries = moodProvider.entries
        .where((e) => !e.createdAt.isBefore(thisWeekStart) && !e.createdAt.isAfter(now))
        .toList();
    final lastWeekEntries = moodProvider.entries
        .where((e) => !e.createdAt.isBefore(lastWeekStart) && e.createdAt.isBefore(thisWeekStart))
        .toList();
    if (thisWeekEntries.isEmpty || lastWeekEntries.isEmpty) {
      return null;
    }
    final thisAvg = thisWeekEntries.fold<int>(0, (acc, e) => acc + e.moodScore) / thisWeekEntries.length;
    final lastAvg = lastWeekEntries.fold<int>(0, (acc, e) => acc + e.moodScore) / lastWeekEntries.length;
    if (lastAvg == 0) {
      return null;
    }
    final diff = thisAvg - lastAvg;
    if (diff.abs() < 0.1) {
      return 'Your mood has been steady compared to last week.';
    }
    final percent = (diff / lastAvg * 100).round();
    if (percent > 0) {
      return 'Your mood improved $percent% compared to last week.';
    } else {
      return 'Your mood is $percent% lower than last week. Be gentle with yourself.';
    }
  }

  void setPeriod(InsightsPeriod value) {
    period = value;
    notifyListeners();
  }

  int _streakFromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    final byDay = <DateTime, bool>{};
    for (final entry in entries) {
      final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      byDay[day] = true;
    }
    int streak = 0;
    var cursor = DateTime.now();
    while (true) {
      final day = DateTime(cursor.year, cursor.month, cursor.day);
      if (byDay[day] == true) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}


