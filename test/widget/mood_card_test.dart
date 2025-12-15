import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/models/mood_entry.dart';
import 'package:mental_zen/widgets/cards/mood_card.dart';

void main() {
  testWidgets('MoodCard displays score and note and responds to tap', (tester) async {
    var tapped = false;
    final entry = MoodEntry(
      id: 'm1',
      userId: 'u1',
      moodScore: 7,
      note: 'Feeling good',
      createdAt: DateTime(2024, 1, 1, 8),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodCard(
            entry: entry,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Feeling good'), findsOneWidget);
    await tester.tap(find.byType(MoodCard));
    await tester.pumpAndSettle();
    expect(tapped, true);
  });
}


