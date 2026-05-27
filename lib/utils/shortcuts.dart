// ignore_for_file: always_put_control_body_on_new_line

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/core/providers/configuration.dart';
import '../features/core/providers/photos.dart';
import '../features/core/providers/placement_validation.dart';
import '../features/core/providers/shortcuts.dart';
import '../features/photo/photoIndex.dart';
import '../models/photo.dart';
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
  bool isEnabled(covariant PreviousIntent intent) {
    return _shortcutsEnabled(ref) && _hasPrevious(ref, index);
  }

  @override
  void invoke(covariant PreviousIntent intent) {
    if (!isEnabled(intent)) return;
    final currentPhoto = photo;
    if (currentPhoto == null) return;
    processAction(context, ref, currentPhoto, index, Status.none, -1);
  }
}

class NextAction extends BaseAction<NextIntent> {
  NextAction(super.context, super.ref);

  @override
  bool isEnabled(covariant NextIntent intent) {
    return _shortcutsEnabled(ref) && _hasNext(ref, index);
  }

  @override
  void invoke(covariant NextIntent intent) {
    if (!isEnabled(intent)) return;
    final currentPhoto = photo;
    if (currentPhoto == null) return;
    processAction(context, ref, currentPhoto, index, Status.skipped, 1);
  }
}

class UnmarkAction extends BaseAction<UnmarkIntent> {
  UnmarkAction(super.context, super.ref);

  @override
  bool isEnabled(covariant UnmarkIntent intent) {
    return _shortcutsEnabled(ref) && _canDontMark(ref, index);
  }

  @override
  void invoke(covariant UnmarkIntent intent) {
    if (!isEnabled(intent)) return;
    final currentPhoto = photo;
    if (currentPhoto == null) return;
    processAction(context, ref, currentPhoto, index, Status.keptUnmarked, 1);
  }
}

class MarkAction extends BaseAction<MarkIntent> {
  MarkAction(super.context, super.ref);

  @override
  bool isEnabled(covariant MarkIntent intent) {
    return _shortcutsEnabled(ref) && _canMark(ref, index);
  }

  @override
  void invoke(covariant MarkIntent intent) {
    if (!isEnabled(intent)) return;
    final currentPhoto = photo;
    if (currentPhoto == null) return;
    processAction(context, ref, currentPhoto, index, Status.marked, 1);
  }
}

bool _shortcutsEnabled(WidgetRef ref) {
  return ref.read(shortcutsProvider);
}

bool _hasPath(String? path) {
  return path != null && path.trim().isNotEmpty;
}

bool _isInRange(WidgetRef ref, int index) {
  final total = ref.read(photosProvider.select((value) => value.length));
  return total > 0 && index >= 0 && index < total;
}

bool _hasPrevious(WidgetRef ref, int index) {
  if (!_isInRange(ref, index)) {
    return false;
  }
  return index > 0;
}

bool _hasNext(WidgetRef ref, int index) {
  final total = ref.read(photosProvider.select((value) => value.length));
  return total > 0 && index >= 0 && index < total - 1;
}

bool _canDontMark(WidgetRef ref, int index) {
  if (!_isInRange(ref, index)) {
    return false;
  }
  final outputPath = ref.read(
    configurationProvider.select((value) => value.outputPath),
  );
  return _hasPath(outputPath);
}

bool _canMark(WidgetRef ref, int index) {
  if (!_isInRange(ref, index)) {
    return false;
  }
  final config = ref.read(configurationProvider);
  if (!_hasPath(config.outputPath) || !_hasPath(config.watermarkPath)) {
    return false;
  }
  return ref.read(placementValidationProvider).isValid;
}
