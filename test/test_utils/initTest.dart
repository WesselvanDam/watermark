import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermarker/app.dart';
import 'package:watermarker/i18n/strings.g.dart';
import 'package:watermarker/utils/providerObserver.dart';

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
