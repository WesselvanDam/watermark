import 'dart:io';

import 'package:image/image.dart' as img;

import '../models/config.dart';
import '../models/photo.dart';

Future<img.Image> resizeImage(img.Image image, Config config) async {
  const maxDim = 1920;
  final width = image.width;
  final height = image.height;
  return img.copyResize(
    image,
    width: width > height ? maxDim : null,
    height: width > height ? null : maxDim,
    maintainAspect: true,
  );
}

Future<img.Image> markImage(Photo photo, Config config) async {
  final original = img.decodeImage(photo.original.readAsBytesSync())!;
  final watermark =
      img.decodeImage(File(config.watermarkPath!).readAsBytesSync())!;

  final resizedOriginal = await resizeImage(original, config);
  final resizedWatermark = await resizeImage(watermark, config);

  final watermarkWidth = resizedOriginal.width * config.watermarkWidthFraction;
  final watermarkHeight =
      watermarkWidth / resizedWatermark.width * resizedWatermark.height;
  final watermarkLeft =
      (resizedOriginal.width * config.watermarkLeftFraction) - watermarkWidth;
  final watermarkTop =
      (resizedOriginal.height * config.watermarkTopFraction) - watermarkHeight;
  img.compositeImage(
    resizedOriginal,
    resizedWatermark,
    dstX: watermarkLeft.toInt(),
    dstY: watermarkTop.toInt(),
    dstW: watermarkWidth.toInt(),
    dstH: watermarkHeight.toInt(),
  );

  return resizedOriginal;
}
