import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../features/core/providers/configuration.dart';
import '../features/core/providers/parameters.dart';
import 'output_template.dart';
import 'status.dart';

String generateOutputPath(WidgetRef ref, {Status status = Status.marked}) {
  final config = ref.read(configurationProvider);
  final format = config.outputFileNameFormat;
  if (format == null) {
    throw Exception('Output file name format is not set');
  }

  final outputPath = renderOutputTemplate(
    format,
    values: {
      'folder': ref.read(parameterProvider('folder')),
      'filename': ref.read(parameterProvider('file')),
      'number': ref.read(parameterProvider('number')),
      'status': switch (status) {
        Status.marked => 'watermarked',
        Status.keptUnmarked => 'original',
        _ => '{status}',
      },
    },
  );
  final resolvedOutputPath = join(config.outputPath!, '$outputPath.jpg');
  if (status != Status.marked && status != Status.keptUnmarked) {
    return resolvedOutputPath;
  }

  final outputDirectory = dirname(resolvedOutputPath);
  if (!Directory(outputDirectory).existsSync()) {
    Directory(outputDirectory).createSync(recursive: true);
  }
  return resolvedOutputPath;
}
