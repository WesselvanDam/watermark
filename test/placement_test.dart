import 'package:flutter_test/flutter_test.dart';

import 'package:watermarker/models/config.dart';
import 'package:watermarker/utils/placement.dart';

void main() {
  const imageWidth = 1000.0;
  const imageHeight = 800.0;
  const watermarkWidth = 200.0;
  const watermarkHeight = 100.0;

  test('top-left anchor at 0/0 places watermark at the top-left corner', () {
    final result = validatePlacement(
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      watermarkSourceWidth: watermarkWidth,
      watermarkSourceHeight: watermarkHeight,
      config: const Config(
        watermarkLeftFraction: 0,
        watermarkTopFraction: 0,
        watermarkAnchorX: 0,
        watermarkAnchorY: 0,
      ),
    );

    expect(result.isValid, isTrue);
    expect(result.rect?.left, 0);
    expect(result.rect?.top, 0);
  });

  test(
    'bottom-right anchor at 1/1 places watermark at the bottom-right corner',
    () {
      final result = validatePlacement(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        watermarkSourceWidth: watermarkWidth,
        watermarkSourceHeight: watermarkHeight,
        config: const Config(watermarkLeftFraction: 1, watermarkTopFraction: 1),
      );

      expect(result.isValid, isTrue);
      expect(result.rect?.right, imageWidth);
      expect(result.rect?.bottom, imageHeight);
      expect(result.rect?.left, imageWidth - 200);
      expect(result.rect?.top, imageHeight - 100);
    },
  );

  test(
    'top-left anchor at 1/1 is invalid because the watermark would overflow',
    () {
      final result = validatePlacement(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        watermarkSourceWidth: watermarkWidth,
        watermarkSourceHeight: watermarkHeight,
        config: const Config(
          watermarkLeftFraction: 1,
          watermarkTopFraction: 1,
          watermarkAnchorX: 0,
          watermarkAnchorY: 0,
        ),
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('right edge'));
    },
  );

  test(
    'bottom-right anchor at 0/0 is invalid because the watermark would overflow',
    () {
      final result = validatePlacement(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        watermarkSourceWidth: watermarkWidth,
        watermarkSourceHeight: watermarkHeight,
        config: const Config(watermarkLeftFraction: 0, watermarkTopFraction: 0),
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('left edge'));
    },
  );
}
