import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../i18n/strings.g.dart';
import '../../../models/config.dart';
import '../../../utils/notifierUpdater.dart';
import 'prefs.dart';

part 'configuration.g.dart';

@Riverpod(keepAlive: true)
class Configuration extends _$Configuration with NotifierUpdater<Config> {
  @override
  Config build() {
    final prefs = ref.watch(prefsProvider);
    
    listenSelf((previous, next) {
      if (previous != null && previous != next) {
        prefs.setString('config', jsonEncode(next.toJson()));
      }
    });

    final storedConfig = prefs.getString('config');
    if (storedConfig != null) {
      return Config.fromJson(jsonDecode(storedConfig) as Map<String, dynamic>);
    }
    return Config(
      outputFileNameFormat:
          '{${t.workspace.parameters.folder.key}}$separator{status}$separator{filename}_{${t.workspace.parameters.number.key}}',
    );
  }
}
