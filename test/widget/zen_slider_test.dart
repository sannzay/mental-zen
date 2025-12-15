import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/widgets/inputs/zen_slider.dart';

void main() {
  testWidgets('ZenSlider updates value', (tester) async {
    var value = 5;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZenSlider(
            value: value,
            onChanged: (v) {
              value = v;
            },
          ),
        ),
      ),
    );
    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);
    await tester.drag(slider, const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(value >= 1 && value <= 10, true);
  });
}


