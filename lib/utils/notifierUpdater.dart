import 'package:riverpod_annotation/riverpod_annotation.dart';

mixin NotifierUpdater<T> on $Notifier<T> {
  void update(T Function(T state) cb) => state = cb(state);
}
