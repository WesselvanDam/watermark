import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shortcuts.g.dart';

@Riverpod(keepAlive: true)
class Shortcuts extends _$Shortcuts {
  @override
  bool build() => false;

  // ignore: use_setters_to_change_properties
  void update(bool active) => state = active;
}
