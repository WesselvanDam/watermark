import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../i18n/strings.g.dart';

part 'parameters.g.dart';

@Riverpod(keepAlive: true)
class Parameter extends _$Parameter {
  @override
  String build(String key) {
    return t['select.parameters.$key.initialValue'].toString();
  }

  void update(String Function(String) cb) {
    state = cb(state);
  }
}
