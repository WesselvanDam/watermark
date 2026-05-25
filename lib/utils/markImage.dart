import 'dart:io';

import 'package:image/image.dart' as img;

import '../models/config.dart';
import '../models/photo.dart';
import 'placement.dart';

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
  final watermark = img.decodeImage(
    File(config.watermarkPath!).readAsBytesSync(),
  )!;

  final resizedOriginal = await resizeImage(original, config);
  final resizedWatermark = await resizeImage(watermark, config);

  final placement = validatePlacement(
    imageWidth: resizedOriginal.width.toDouble(),
    imageHeight: resizedOriginal.height.toDouble(),
    watermarkSourceWidth: resizedWatermark.width.toDouble(),
    watermarkSourceHeight: resizedWatermark.height.toDouble(),
    config: config,
  );
  if (!placement.isValid || placement.rect == null) {
    throw StateError(placement.message ?? 'Invalid watermark placement.');
  }

  final rect = placement.rect!;
  img.compositeImage(
    resizedOriginal,
    resizedWatermark,
    dstX: rect.left.toInt(),
    dstY: rect.top.toInt(),
    dstW: rect.width.toInt(),
    dstH: rect.height.toInt(),
  );

  return resizedOriginal;
}
