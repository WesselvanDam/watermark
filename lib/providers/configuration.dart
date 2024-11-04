import 'dart:convert';

import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../i18n/strings.g.dart';
import '../models/config.dart';
import '../utils/notifierUpdater.dart';
import 'prefs.dart';

part 'configuration.g.dart';

@Riverpod(keepAlive: true)
class Configuration extends _$Configuration with NotifierUpdater<Config> {
  @override
  Config build() {
    final prefs = ref.watch(prefsProvider);
    final storedConfig = prefs.getString('config');
    if (storedConfig != null) {
      return Config.fromJson(jsonDecode(storedConfig) as Map<String, dynamic>);
    }
    return Config(
      outputFileNameFormat:
          '{{${t.select.parameters.folder.key}}}$separator{{status}}$separator{{${t.select.parameters.file.key}}}_{{${t.select.parameters.number.key}}}',
    );
  }
}
