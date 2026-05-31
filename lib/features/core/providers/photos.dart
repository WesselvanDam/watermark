import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/photo.dart';
import '../../../utils/status.dart';
import 'configuration.dart';

part 'photos.g.dart';

@Riverpod(keepAlive: true)
class Photos extends _$Photos {
  @override
  List<Photo> build() {
    final imageSourcepath = ref.watch(
      configurationProvider.select((value) => value.inputPath),
    );
    final includeSubdirectories = ref.watch(
      configurationProvider.select((value) => value.includeSubdirectories),
    );
    if (imageSourcepath == null) {
      return [];
    }
    if (!Directory(imageSourcepath).existsSync()) {
      return [];
    }
    return Directory(imageSourcepath)
        .listSync(recursive: includeSubdirectories)
        .where((element) {
          return element is File &&
              [
                'jpg',
                'jpeg',
                'png',
                'gif',
                'bmp',
                'webp',
              ].contains(element.path.toLowerCase().split('.').last);
        })
        .map((e) => Photo(original: e as File))
        .toList();
  }

  void updateAtIndex(int index, Photo Function(Photo) cb) {
    final newState = List<Photo>.from(state);
    newState[index] = cb(newState[index]).copyWith(modifiedTime: DateTime.now());
    state = newState;
  }

  void skip(int index) {
    updateAtIndex(index, (photo) => photo.copyWith(status: Status.skipped));
  }

  void unmark(int index, String unmarkedPath) {
    updateAtIndex(
      index,
      (photo) => photo.copyWith(
        status: Status.keptUnmarked,
        unmarkedPath: unmarkedPath,
      ),
    );
  }

  void mark(int index, String unMarkedPath, String markedPath) {
    updateAtIndex(
      index,
      (photo) => photo.copyWith(
        status: Status.marked,
        markedPath: markedPath,
        unmarkedPath: unMarkedPath,
      ),
    );
  }

  Future<int> deleteSkipped() async {
    if (state.isEmpty) {
      return 0;
    }

    final remaining = <Photo>[];
    final failedDeletes = <Photo>[];
    var movedCount = 0;

    for (final photo in state) {
      if (photo.status != Status.skipped) {
        remaining.add(photo);
        continue;
      }

      try {
        await photo.original.delete();
        debugPrint('Deleted: ${photo.original.path}');
        movedCount += 1;
      } catch (e) {
        debugPrint('Failed to delete ${photo.original.path}: $e');
        remaining.add(photo);
        failedDeletes.add(photo);
      }
    }

    if (movedCount > 0) {
      state = remaining;
    }

    if (failedDeletes.isNotEmpty) {
      throw Exception(
        'Failed to delete ${failedDeletes.length} skipped photos:\n\n${failedDeletes.map((e) => e.original.path).join('\n')}',
      );
    }

    return movedCount;
  }
}
