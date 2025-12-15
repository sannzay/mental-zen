import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/models/journal_entry.dart';
import 'package:mental_zen/widgets/cards/journal_card.dart';

void main() {
  testWidgets('JournalCard displays data and favorite icon', (tester) async {
    final entry = JournalEntry(
      id: 'j1',
      userId: 'u1',
      title: 'Title',
      content: 'Content',
      isFavorite: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JournalCard(
            entry: entry,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
  });
}


