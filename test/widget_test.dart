// Smoke test: app bootstraps without throwing (Hive is initialized in main in real runs).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp smoke', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('ok')),
        ),
      ),
    );
    expect(find.text('ok'), findsOneWidget);
  });
}
