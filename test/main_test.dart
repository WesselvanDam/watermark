import 'package:flutter/material.dart';
import 'package:flutter_template/pages/home/homePage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_utils/extensions.dart';
import 'test_utils/initTest.dart';

void main() {
  // Add a WidgetTest for the main.dart file
  group('Main', () {
    testWidgets('App Widget builds with MaterialApp', (tester) async {
      await initTest(tester);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App starts on Home Page', (tester) async {
      await initTest(tester);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Navigating to undefined route shows 404', (tester) async {
      await initTest(tester);

      final context = tester.element(find.byType(HomePage));
      context.go('/undefined');

      await tester.pumpAndSettle();
      expect(find.text('404'), findsOneWidget);
    });
  });
}
