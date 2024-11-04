import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/status.dart';

part 'photo.freezed.dart';

@freezed
class Photo with _$Photo {
  const factory Photo({
    required File original,
    @Default(Status.none) Status status,
    @Default(null) String? markedPath,
    @Default(null) String? unmarkedPath,
  }) = _Photo;
}
