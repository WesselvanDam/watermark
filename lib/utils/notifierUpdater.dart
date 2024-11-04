import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin NotifierUpdater<T> on Notifier<T> {
  void update(T Function(T state) cb) => state = cb(state);
}
