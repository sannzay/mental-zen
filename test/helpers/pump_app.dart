import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget pumpApp(WidgetTester tester, Widget child) {
  final app = MaterialApp(
    home: child,
  );
  return tester.pumpWidget(app);
}


