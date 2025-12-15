import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/widgets/buttons/zen_button.dart';

void main() {
  testWidgets('ZenButton shows label and triggers callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZenButton(
            label: 'Tap',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );
    expect(find.text('Tap'), findsOneWidget);
    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();
    expect(tapped, true);
  });

  testWidgets('ZenButton shows loading spinner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZenButton(
            label: 'Tap',
            loading: true,
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}


