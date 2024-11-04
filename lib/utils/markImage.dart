import 'dart:io';

import 'package:image/image.dart' as img;

import '../models/config.dart';
import '../models/photo.dart';

Future<img.Image> markImage(Photo photo, Config config) async {
  final original = img.decodeImage(photo.original.readAsBytesSync())!;
  final watermark =
      img.decodeImage(File(config.watermarkPath!).readAsBytesSync())!;

  final watermarkWidth = original.width * config.watermarkWidthFraction;
  final watermarkHeight = watermarkWidth / watermark.width * watermark.height;
  final watermarkLeft =
      (original.width * config.watermarkLeftFraction) - watermarkWidth;
  final watermarkTop =
      (original.height * config.watermarkTopFraction) - watermarkHeight;
  img.compositeImage(
    original,
    watermark,
    dstX: watermarkLeft.toInt(),
    dstY: watermarkTop.toInt(),
    dstW: watermarkWidth.toInt(),
    dstH: watermarkHeight.toInt(),
  );

  return original;
}
