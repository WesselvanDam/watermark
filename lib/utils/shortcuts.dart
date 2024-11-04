// ignore_for_file: always_put_control_body_on_new_line

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/photo.dart';
import '../pages/home/photoIndex.dart';
import '../providers/photos.dart';
import '../providers/shortcuts.dart';
import 'processPhoto.dart';
import 'status.dart';

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class UnmarkIntent extends Intent {
  const UnmarkIntent();
}

class MarkIntent extends Intent {
  const MarkIntent();
}

abstract class BaseAction<T extends Intent> extends Action<T> {
  BaseAction(this.context, this.ref);
  final BuildContext context;
  final WidgetRef ref;

  int get index => ref.read(photoIndexProvider);
  Photo? get photo => ref.read(
        photosProvider.select((value) => value.isEmpty ? null : value[index]),
      );
}

class PreviousAction extends BaseAction<PreviousIntent> {
  PreviousAction(super.context, super.ref);

  @override
  void invoke(covariant PreviousIntent intent) {
    if (photo == null) return;
    if (!ref.watch(shortcutsProvider)) return;
    processAction(context, ref, photo!, index, Status.none, -1);
  }
}

class NextAction extends BaseAction<NextIntent> {
  NextAction(super.context, super.ref);

  @override
  void invoke(covariant NextIntent intent) {
    if (photo == null) return;
    if (!ref.watch(shortcutsProvider)) return;
    processAction(context, ref, photo!, index, Status.skipped, 1);
  }
}

class UnmarkAction extends BaseAction<UnmarkIntent> {
  UnmarkAction(super.context, super.ref);

  @override
  void invoke(covariant UnmarkIntent intent) {
    if (photo == null) return;
    if (!ref.watch(shortcutsProvider)) return;
    processAction(context, ref, photo!, index, Status.keptUnmarked, 1);
  }
}

class MarkAction extends BaseAction<MarkIntent> {
  MarkAction(super.context, super.ref);

  @override
  void invoke(covariant MarkIntent intent) {
    if (photo == null) return;
    if (!ref.watch(shortcutsProvider)) return;
    processAction(context, ref, photo!, index, Status.marked, 1);
  }
}
