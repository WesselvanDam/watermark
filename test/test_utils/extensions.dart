import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtensions on WidgetTester {
  ProviderContainer get container =>
      ProviderScope.containerOf(element(find.byType(MaterialApp)));

  ProviderContainer get containerOfWidgetTest =>
      ProviderScope.containerOf(context);

  /// Get the [BuildContext] of the [Scaffold] widget. If no [Scaffold] is
  /// found, it will throw an error. In those cases, use:
  /// ```dart
  /// final context = tester.element(find.byType(<Widget>));
  /// ```
  /// Where `<Widget>` is the widget you want to find the [BuildContext] of, 
  /// e.g. 'HomePage'.
  BuildContext get context => element(find.byType(Scaffold));
}
