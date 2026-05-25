import '../models/config.dart';

class PlacementRect {
  const PlacementRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
}

enum PlacementValidationStatus { unavailable, valid, invalid }

class PlacementValidationResult {
  const PlacementValidationResult.unavailable(this.message)
    : status = PlacementValidationStatus.unavailable,
      rect = null;

  const PlacementValidationResult.valid(this.rect)
    : status = PlacementValidationStatus.valid,
      message = null;

  const PlacementValidationResult.invalid(this.message, this.rect)
    : status = PlacementValidationStatus.invalid;

  final PlacementValidationStatus status;
  final String? message;
  final PlacementRect? rect;

  bool get isValid => status == PlacementValidationStatus.valid;
  bool get isAvailable => status != PlacementValidationStatus.unavailable;
}

PlacementValidationResult validatePlacement({
  required double imageWidth,
  required double imageHeight,
  required double watermarkSourceWidth,
  required double watermarkSourceHeight,
  required Config config,
}) {
  if (imageWidth <= 0 || imageHeight <= 0) {
    return const PlacementValidationResult.unavailable(
      'Validation needs a valid input image.',
    );
  }
  if (watermarkSourceWidth <= 0 || watermarkSourceHeight <= 0) {
    return const PlacementValidationResult.unavailable(
      'Validation needs a valid watermark image.',
    );
  }

  final fractions = <String, double>{
    'left': config.watermarkLeftFraction,
    'top': config.watermarkTopFraction,
    'width': config.watermarkWidthFraction,
    'anchorX': config.watermarkAnchorX,
    'anchorY': config.watermarkAnchorY,
  };
  for (final entry in fractions.entries) {
    if (entry.value < 0 || entry.value > 1) {
      final rect = _placementRect(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        watermarkSourceWidth: watermarkSourceWidth,
        watermarkSourceHeight: watermarkSourceHeight,
        config: config,
      );
      return PlacementValidationResult.invalid(
        '${entry.key} must be between 0 and 1.',
        rect,
      );
    }
  }

  final rect = _placementRect(
    imageWidth: imageWidth,
    imageHeight: imageHeight,
    watermarkSourceWidth: watermarkSourceWidth,
    watermarkSourceHeight: watermarkSourceHeight,
    config: config,
  );

  if (rect.left < 0) {
    return PlacementValidationResult.invalid(
      'Watermark extends past the left edge.',
      rect,
    );
  }
  if (rect.top < 0) {
    return PlacementValidationResult.invalid(
      'Watermark extends past the top edge.',
      rect,
    );
  }
  if (rect.right > imageWidth) {
    return PlacementValidationResult.invalid(
      'Watermark extends past the right edge.',
      rect,
    );
  }
  if (rect.bottom > imageHeight) {
    return PlacementValidationResult.invalid(
      'Watermark extends past the bottom edge.',
      rect,
    );
  }

  return PlacementValidationResult.valid(rect);
}

PlacementRect _placementRect({
  required double imageWidth,
  required double imageHeight,
  required double watermarkSourceWidth,
  required double watermarkSourceHeight,
  required Config config,
}) {
  final watermarkWidth = imageWidth * config.watermarkWidthFraction;
  final watermarkHeight =
      watermarkWidth / watermarkSourceWidth * watermarkSourceHeight;
  final left =
      imageWidth * config.watermarkLeftFraction -
      (watermarkWidth * config.watermarkAnchorX);
  final top =
      imageHeight * config.watermarkTopFraction -
      (watermarkHeight * config.watermarkAnchorY);
  return PlacementRect(
    left: left,
    top: top,
    width: watermarkWidth,
    height: watermarkHeight,
  );
}
