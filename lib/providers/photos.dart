import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/photo.dart';
import '../utils/status.dart';
import 'configuration.dart';

part 'photos.g.dart';

@Riverpod(keepAlive: true)
class Photos extends _$Photos {
  @override
  List<Photo> build() {
    final imageSourcepath =
        ref.watch(configurationProvider.select((value) => value.inputPath));
    if (imageSourcepath == null) {
      return [];
    }
    return Directory(imageSourcepath)
        .listSync(recursive: true)
        .where(
          (element) {
            return element is File &&
                ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
                    .contains(element.path.toLowerCase().split('.').last);
          },
        )
        .map((e) => Photo(original: e as File))
        .toList();
  }

  void updateAtIndex(int index, Photo Function(Photo) cb) {
    state[index] = cb(state[index]);
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
}
