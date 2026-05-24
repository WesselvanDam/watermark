import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'configuration.dart';

part 'watermark.g.dart';

@Riverpod(keepAlive: true)
Future<ui.Image?> watermark(Ref ref) async {
  final watermarkPath = ref.watch(
    configurationProvider.select((value) => value.watermarkPath),
  );
  if (watermarkPath == null) {
    return null;
  }
  final bytes = await File(watermarkPath).readAsBytes();
  return await decodeImageFromList(bytes);
}
