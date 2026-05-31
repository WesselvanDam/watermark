import 'package:flutter_test/flutter_test.dart';

import 'package:watermarker/models/config.dart';

void main() {
  test('round-trips the output max size settings through JSON', () {
    const config = Config(originalMaxSize: 2400, watermarkedMaxSize: 1200);

    final decoded = Config.fromJson(config.toJson());

    expect(decoded.originalMaxSize, 2400);
    expect(decoded.watermarkedMaxSize, 1200);
  });

  test('treats missing output max size fields as null', () {
    final decoded = Config.fromJson(const <String, dynamic>{});

    expect(decoded.originalMaxSize, isNull);
    expect(decoded.watermarkedMaxSize, isNull);
  });

  test('defaults to including subdirectories when the field is missing', () {
    final decoded = Config.fromJson(const <String, dynamic>{});

    expect(decoded.includeSubdirectories, isTrue);
  });

  test('round-trips the include subdirectories setting through JSON', () {
    const config = Config(includeSubdirectories: false);

    final decoded = Config.fromJson(config.toJson());

    expect(decoded.includeSubdirectories, isFalse);
  });
}
