import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../features/core/providers/configuration.dart';
import '../features/core/providers/parameters.dart';
import '../features/core/providers/photos.dart';
import '../features/photo/photoIndex.dart';
import '../i18n/strings.g.dart';
import '../models/config.dart';
import '../models/photo.dart';
import 'generateOutputPath.dart';
import 'photo_queue_state.dart';
import 'placement.dart';
import 'status.dart';

final Map<String, Future<void>> _pendingPhotoActions = {};

img.Image _resize(img.Image image, int? maxDim) {
  if (maxDim == null || maxDim <= 0) {
    return image;
  }

  final width = image.width;
  final height = image.height;
  return img.copyResize(
    image,
    width: width > height ? min(width, maxDim) : null,
    height: width > height ? null : min(height, maxDim),
    maintainAspect: true,
  );
}

Future<img.Image> _placeWatermark(Photo photo, Config config) async {
  final original = img.decodeImage(photo.original.readAsBytesSync())!;
  final watermark = img.decodeImage(
    File(config.watermarkPath!).readAsBytesSync(),
  )!;

  final resizedOriginal = _resize(original, config.watermarkedMaxSize);

  final placement = validatePlacement(
    imageWidth: resizedOriginal.width.toDouble(),
    imageHeight: resizedOriginal.height.toDouble(),
    watermarkSourceWidth: watermark.width.toDouble(),
    watermarkSourceHeight: watermark.height.toDouble(),
    config: config,
  );
  if (!placement.isValid || placement.rect == null) {
    throw StateError(placement.message ?? 'Invalid watermark placement.');
  }

  final rect = placement.rect!;
  img.compositeImage(
    resizedOriginal,
    watermark,
    dstX: rect.left.toInt(),
    dstY: rect.top.toInt(),
    dstW: rect.width.toInt(),
    dstH: rect.height.toInt(),
  );

  return resizedOriginal;
}

Future<Photo> _skip(Photo photo) async {
  return photo.copyWith(status: Status.skipped);
}

Map<String, String> _captureParameterValues(WidgetRef ref) {
  return {
    'folder': ref.read(parameterProvider(t.workspace.parameters.folder.key)),
    'filename': ref.read(parameterProvider(t.workspace.parameters.file.key)),
    'number': ref.read(parameterProvider(t.workspace.parameters.number.key)),
  };
}

Future<Photo> _removeUnmarked(Photo photo) async {
  if (photo.unmarkedPath != null) {
    return File(
      photo.unmarkedPath!,
    ).delete().then((value) => photo.copyWith(unmarkedPath: null));
  }
  return photo;
}

Future<Photo> _removeMarked(Photo photo) async {
  if (photo.markedPath != null) {
    return File(
      photo.markedPath!,
    ).delete().then((value) => photo.copyWith(markedPath: null));
  }
  return photo;
}

Future<Photo> _unmark(
  Photo photo,
  WidgetRef ref, {
  Config? config,
  Map<String, String>? parameterValues,
}) async {
  final effectiveConfig = config ?? ref.read(configurationProvider);
  final unmarkedPath = generateOutputPath(
    ref,
    status: Status.keptUnmarked,
    parameterValues: parameterValues,
  );
  return await compute(_writeUnmarkedFile, {
    'photo': photo,
    'unmarkedPath': unmarkedPath,
    'config': effectiveConfig,
  });
}

Future<Photo> _mark(
  Photo photo,
  WidgetRef ref, {
  Config? config,
  Map<String, String>? parameterValues,
}) async {
  final effectiveConfig = config ?? ref.read(configurationProvider);
  final markedPath = generateOutputPath(
    ref,
    parameterValues: parameterValues,
  );
  return await compute(_writeMarkedFile, {
    'photo': photo,
    'markedPath': markedPath,
    'config': effectiveConfig,
  });
}

Future<Photo> _unmarkAndMark(
  Photo photo,
  WidgetRef ref, {
  Config? config,
  Map<String, String>? parameterValues,
}) async {
  return await _unmark(
    photo,
    ref,
    config: config,
    parameterValues: parameterValues,
  ).then(
    (value) => _mark(
      value,
      ref,
      config: config,
      parameterValues: parameterValues,
    ),
  );
}

Future<Photo> _writeUnmarkedFile(Map<String, dynamic> args) async {
  final config = args['config'] as Config;
  final photo = args['photo'] as Photo;
  final unmarkedPath = args['unmarkedPath'] as String;

  if (config.originalMaxSize != null && config.originalMaxSize! > 0) {
    final original = img.decodeImage(photo.original.readAsBytesSync())!;
    final resizedOriginal = _resize(original, config.originalMaxSize);
    await File(unmarkedPath).writeAsBytes(img.encodeJpg(resizedOriginal));
  } else {
    await File(unmarkedPath).writeAsBytes(photo.original.readAsBytesSync());
  }
  return photo.copyWith(unmarkedPath: unmarkedPath);
}

Future<Photo> _writeMarkedFile(Map<String, dynamic> args) async {
  final markedImage = await _placeWatermark(
    args['photo'] as Photo,
    args['config'] as Config,
  );
  final markedPath = args['markedPath'] as String;
  final photo = args['photo'] as Photo;
  await File(markedPath).writeAsBytes(img.encodeJpg(markedImage, quality: 90));
  return photo.copyWith(markedPath: markedPath);
}

Future<Photo> processPhoto(
  Photo photo,
  Status status,
  WidgetRef ref, {
  Config? config,
  Map<String, String>? parameterValues,
}) async {
  Photo processedPhoto = photo;
  if (photo.status == status || status == Status.none) {
    // The photo is already in the desired state
    return photo;
  }
  final effectiveConfig = config ?? ref.read(configurationProvider);
  final effectiveParameterValues =
      parameterValues ?? _captureParameterValues(ref);
  if (photo.status == Status.none) {
    // The photo has not been processed yet
    processedPhoto = switch (status) {
      Status.marked => await _unmarkAndMark(
        photo,
        ref,
        config: effectiveConfig,
        parameterValues: effectiveParameterValues,
      ),
      Status.keptUnmarked => await _unmark(
        photo,
        ref,
        config: effectiveConfig,
        parameterValues: effectiveParameterValues,
      ),
      Status.skipped => await _skip(photo),
      Status.none => photo,
    };
  } else if (status == Status.skipped && photo.status != Status.skipped) {
    // The photo was marked or unmarked before, so we need to undo it
    processedPhoto = await _removeMarked(
      photo,
    ).then((value) => _removeUnmarked(value));
  } else if (status == Status.keptUnmarked && photo.status == Status.marked) {
    // The photo was marked before, so we need to undo it
    processedPhoto = await _removeMarked(photo);
  } else if (status == Status.marked && photo.status == Status.keptUnmarked) {
    // The photo was unmarked, but not marked before
    processedPhoto = await _mark(photo, ref);
  } else if (status == Status.keptUnmarked && photo.status == Status.skipped) {
    // The photo was skipped before, so we need to unmark it
    processedPhoto = await _unmark(
      photo,
      ref,
      config: effectiveConfig,
      parameterValues: effectiveParameterValues,
    );
  } else if (status == Status.marked && photo.status == Status.skipped) {
    // The photo was skipped before, so we need to mark and unmark it
    processedPhoto = await _unmark(
      photo,
      ref,
      config: effectiveConfig,
      parameterValues: effectiveParameterValues,
    ).then(
      (value) => _mark(
        value,
        ref,
        config: effectiveConfig,
        parameterValues: effectiveParameterValues,
      ),
    );
  }
  // Update the status of the photo
  return processedPhoto.copyWith(status: status);
}

Future<void> processAction(
  BuildContext context,
  WidgetRef ref,
  Photo photo,
  int index,
  Status status,
  int change,
) async {
  final parameterValues = _captureParameterValues(ref);
  final config = ref.read(configurationProvider);
  final photoKey = photo.original.path;

  final previousAction = _pendingPhotoActions[photoKey] ?? Future<void>.value();
  final action = previousAction
      .catchError((Object error, StackTrace stackTrace) {
        debugPrint('Previous photo action failed for $photoKey: $error');
      })
      .then((_) async {
        try {
          final updatedPhoto = await processPhoto(
            photo,
            status,
            ref,
            config: config,
            parameterValues: parameterValues,
          );
          debugPrint('Updated photo: $updatedPhoto');
          ref
              .read(photosProvider.notifier)
              .updateAtIndex(index, (_) => updatedPhoto);
        } catch (error, stackTrace) {
          debugPrint('Photo action failed for $photoKey: $error');
          debugPrint(stackTrace.toString());
        }
      });

  late final Future<void> trackedAction;
  trackedAction = action.whenComplete(() {
    if (identical(_pendingPhotoActions[photoKey], trackedAction)) {
      _pendingPhotoActions.remove(photoKey);
    }
  });

  _pendingPhotoActions[photoKey] = trackedAction;

  final photos = ref.read(photosProvider);
  final shouldAdvance = shouldAdvancePhotoIndex(index, photos.length, change);

  if (shouldAdvance) {
    // Update the index and the number parameter.
    ref.read(photoIndexProvider.notifier).update((value) => value + change);
    ref
        .read(parameterProvider(t.workspace.parameters.number.key).notifier)
        .update((value) {
          debugPrint(
            'Value: $value. New value: ${(int.tryParse(value) ?? 0) + change}',
          );
          return ((int.tryParse(value) ?? 0) + change).toString();
        });
  }
}
