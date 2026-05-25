// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:watermarker/utils/processPhoto.dart';

void main() {
  test('returns the original image when max size is empty or zero', () {
    final image = img.Image(width: 4000, height: 2000);

    expect(resizeImage(image, null), same(image));
    expect(resizeImage(image, 0), same(image));
  });

  test('resizes landscape images to the configured max dimension', () {
    final image = img.Image(width: 4000, height: 2000);

    final resized = resizeImage(image, 1920);

    expect(resized.width, 1920);
    expect(resized.height, 960);
  });

  test('resizes portrait images to the configured max dimension', () {
    final image = img.Image(width: 2000, height: 4000);

    final resized = resizeImage(image, 1920);

    expect(resized.width, 960);
    expect(resized.height, 1920);
  });
}
