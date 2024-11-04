import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'i18n/strings.g.dart';
import 'providers/prefs.dart';
import 'utils/providerObserver.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      observers: [RiverpodProviderObserver()],
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: TranslationProvider(child: const App()),
    ),
  );
}
