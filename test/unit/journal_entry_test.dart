import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/models/journal_entry.dart';

void main() {
  group('JournalEntry', () {
    test('toJson and fromJson', () {
      final entry = JournalEntry(
        id: 'j1',
        userId: 'u1',
        title: 'Title',
        content: 'Content',
        moodScore: 5,
        tags: ['tag1'],
        isFavorite: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
      final json = entry.toJson();
      final back = JournalEntry.fromJson('j1', {
        ...json,
        'createdAt': entry.createdAt,
        'updatedAt': entry.updatedAt,
      });
      expect(back.title, 'Title');
      expect(back.content, 'Content');
      expect(back.moodScore, 5);
      expect(back.tags, ['tag1']);
      expect(back.isFavorite, true);
    });

    test('copyWith creates new instance with updated fields', () {
      final entry = JournalEntry(
        id: 'j1',
        userId: 'u1',
        title: 'Title',
        content: 'Content',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final updated = entry.copyWith(title: 'New');
      expect(updated.title, 'New');
      expect(entry.title, 'Title');
    });
  });
}


