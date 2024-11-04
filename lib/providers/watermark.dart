import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'configuration.dart';

part 'watermark.g.dart';

@Riverpod(keepAlive: true)
Future<ui.Image?> watermark(WatermarkRef ref) async {
  final watermarkPath =
      ref.watch(configurationProvider.select((value) => value.watermarkPath));
  if (watermarkPath == null) {
    return null;
  }
  return decodeImageFromList(File(watermarkPath).readAsBytesSync());
}
