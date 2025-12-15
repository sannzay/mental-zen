import 'package:mental_zen/models/journal_entry.dart';
import 'package:mental_zen/models/mood_entry.dart';

MoodEntry makeMoodEntry(int score) {
  return MoodEntry(
    id: 'm$score',
    userId: 'u1',
    moodScore: score,
    createdAt: DateTime(2024, 1, score.clamp(1, 28)),
  );
}

JournalEntry makeJournalEntry(String id) {
  return JournalEntry(
    id: id,
    userId: 'u1',
    title: 'Title $id',
    content: 'Content $id',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}


