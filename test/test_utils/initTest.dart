import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/app.dart';
import 'package:flutter_template/i18n/strings.g.dart';
import 'package:flutter_template/utils/providerObserver.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> initTest(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      observers: [RiverpodProviderObserver()],
      child: TranslationProvider(
        child: const App(),
      ),
    ),
  );
}
