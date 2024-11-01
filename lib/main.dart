import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Note: when targeting other platforms, you may need to stub out the following import
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'app.dart';
import 'i18n/strings.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(ProviderScope(child: TranslationProvider(child: const App())));
}
