import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/models/mood_entry.dart';

void main() {
  group('MoodEntry', () {
    test('toJson and fromJson', () {
      final entry = MoodEntry(
        id: 'm1',
        userId: 'u1',
        moodScore: 7,
        note: 'Good day',
        tags: ['Calm'],
        createdAt: DateTime(2024, 1, 1),
      );
      final json = entry.toJson();
      final back = MoodEntry.fromJson('m1', {
        ...json,
        'createdAt': entry.createdAt,
      });
      expect(back.userId, 'u1');
      expect(back.moodScore, 7);
      expect(back.note, 'Good day');
      expect(back.tags, ['Calm']);
    });

    test('moodScore within 1-10 range', () {
      final entry = MoodEntry(
        id: 'm2',
        userId: 'u1',
        moodScore: 10,
        createdAt: DateTime.now(),
      );
      expect(entry.moodScore >= 1 && entry.moodScore <= 10, true);
    });
  });
}


