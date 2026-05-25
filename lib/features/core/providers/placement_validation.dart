import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../../utils/placement.dart';
import 'configuration.dart';
import 'photos.dart';
import 'watermark.dart';
import '../../photo/photoIndex.dart';

final placementValidationProvider = Provider<PlacementValidationResult>((ref) {
  final config = ref.watch(configurationProvider);
  final photos = ref.watch(photosProvider);
  final index = ref.watch(photoIndexProvider);
  final selectedPhoto = (photos.isEmpty || index < 0 || index >= photos.length)
      ? null
      : photos[index];
  final watermark = ref.watch(watermarkProvider).value;

  if (selectedPhoto == null) {
    return const PlacementValidationResult.unavailable(
      'Select an input image to validate placement.',
    );
  }
  if (watermark == null) {
    return const PlacementValidationResult.unavailable(
      'Select a watermark image to validate placement.',
    );
  }

  final bytes = selectedPhoto.original.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return const PlacementValidationResult.unavailable(
      'Unable to read the selected input image.',
    );
  }

  return validatePlacement(
    imageWidth: decoded.width.toDouble(),
    imageHeight: decoded.height.toDouble(),
    watermarkSourceWidth: watermark.width.toDouble(),
    watermarkSourceHeight: watermark.height.toDouble(),
    config: config,
  );
});
