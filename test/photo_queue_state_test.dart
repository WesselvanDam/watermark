import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:watermarker/models/photo.dart';
import 'package:watermarker/utils/photo_queue_state.dart';
import 'package:watermarker/utils/status.dart';

void main() {
  test('stops advancing forward on the last photo', () {
    expect(shouldAdvancePhotoIndex(2, 3, 1), isFalse);
    expect(shouldAdvancePhotoIndex(1, 3, 1), isTrue);
    expect(shouldAdvancePhotoIndex(0, 3, -1), isTrue);
  });

  test('detects when every photo has been processed', () {
    expect(
      allPhotosProcessed([
        Photo(original: File('a.jpg'), status: Status.marked),
        Photo(original: File('b.jpg'), status: Status.skipped),
      ]),
      isTrue,
    );

    expect(
      allPhotosProcessed([
        Photo(original: File('a.jpg'), status: Status.marked),
        Photo(original: File('b.jpg')),
      ]),
      isFalse,
    );
  });
}
