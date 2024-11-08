import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../i18n/strings.g.dart';
import '../models/config.dart';
import '../models/photo.dart';
import '../pages/home/photoIndex.dart';
import '../providers/configuration.dart';
import '../providers/parameters.dart';
import '../providers/photos.dart';
import 'generateOutputPath.dart';
import 'markImage.dart';
import 'status.dart';

Future<Photo> _skip(Photo photo) async {
  return photo.copyWith(status: Status.skipped);
}

Future<Photo> _removeUnmarked(Photo photo) async {
  if (photo.unmarkedPath != null) {
    return File(photo.unmarkedPath!)
        .delete()
        .then((value) => photo.copyWith(unmarkedPath: null));
  }
  return photo;
}

Future<Photo> _removeMarked(Photo photo) async {
  if (photo.markedPath != null) {
    return File(photo.markedPath!)
        .delete()
        .then((value) => photo.copyWith(markedPath: null));
  }
  return photo;
}

Future<Photo> _unmark(Photo photo, WidgetRef ref) async {
  final unmarkedPath = generateOutputPath(ref, status: Status.keptUnmarked);
  return await compute(
    _writeUnmarkedFile,
    {'photo': photo, 'unmarkedPath': unmarkedPath},
  );
}

Future<Photo> _mark(Photo photo, WidgetRef ref) async {
  final config = ref.read(configurationProvider);
  final markedPath = generateOutputPath(ref);
  return await compute(
    _writeMarkedFile,
    {'photo': photo, 'markedPath': markedPath, 'config': config},
  );
}

Future<Photo> _unmarkAndMark(Photo photo, WidgetRef ref) async {
  return await _unmark(photo, ref).then((value) => _mark(value, ref));
}

Future<Photo> _writeUnmarkedFile(Map<String, dynamic> args) async {
  final photo = args['photo'] as Photo;
  final unmarkedPath = args['unmarkedPath'] as String;
  await File(unmarkedPath).writeAsBytes(photo.original.readAsBytesSync());
  return photo.copyWith(unmarkedPath: unmarkedPath);
}

Future<Photo> _writeMarkedFile(Map<String, dynamic> args) async {
  final markedImage =
      await markImage(args['photo'] as Photo, args['config'] as Config);
  final markedPath = args['markedPath'] as String;
  final photo = args['photo'] as Photo;
  await File(markedPath).writeAsBytes(img.encodeJpg(markedImage, quality: 90));
  return photo.copyWith(markedPath: markedPath);
}

Future<Photo> processPhoto(Photo photo, Status status, WidgetRef ref) async {
  Photo processedPhoto = photo;
  if (photo.status == status || status == Status.none) {
    // The photo is already in the desired state
    return photo;
  }
  if (photo.status == Status.none) {
    // The photo has not been processed yet
    processedPhoto = switch (status) {
      Status.marked => await _unmarkAndMark(photo, ref),
      Status.keptUnmarked => await _unmark(photo, ref),
      Status.skipped => await _skip(photo),
      Status.none => photo,
    };
  } else if (status == Status.skipped && photo.status != Status.skipped) {
    // The photo was marked or unmarked before, so we need to undo it
    processedPhoto =
        await _removeMarked(photo).then((value) => _removeUnmarked(value));
  } else if (status == Status.keptUnmarked && photo.status == Status.marked) {
    // The photo was marked before, so we need to undo it
    processedPhoto = await _removeMarked(photo);
  } else if (status == Status.marked && photo.status == Status.keptUnmarked) {
    // The photo was unmarked, but not marked before
    processedPhoto = await _mark(photo, ref);
  } else if (status == Status.keptUnmarked && photo.status == Status.skipped) {
    // The photo was skipped before, so we need to unmark it
    processedPhoto = await _unmark(photo, ref);
  } else if (status == Status.marked && photo.status == Status.skipped) {
    // The photo was skipped before, so we need to mark and unmark it
    processedPhoto =
        await _unmark(photo, ref).then((value) => _mark(value, ref));
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
  // Process the photo with the given status
  processPhoto(photo, status, ref).then(
    (updatedPhoto) {
      debugPrint('Updated photo: $updatedPhoto');
      ref.read(photosProvider.notifier).updateAtIndex(
            index,
            (photo) => updatedPhoto,
          );
    },
  );

  // Update the index and the number parameter
  ref.read(photoIndexProvider.notifier).update((value) => value + change);
  ref.read(parameterProvider(t.select.parameters.number.key).notifier).update(
    (value) {
      debugPrint(
        'Value: $value. New value: ${(int.tryParse(value) ?? 0) + change}',
      );
      return ((int.tryParse(value) ?? 0) + change).toString();
    },
  );
}
