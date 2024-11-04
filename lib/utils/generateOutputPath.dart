import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../i18n/strings.g.dart';
import '../providers/configuration.dart';
import '../providers/parameters.dart';
import 'status.dart';

String generateOutputPath(WidgetRef ref, {Status status = Status.marked}) {
  final config = ref.read(configurationProvider);
  final format = config.outputFileNameFormat;
  if (format == null) {
    throw Exception('Output file name format is not set');
  }

  // Replace the placeholders in the output file name format
  final parameters = [
    t.select.parameters.folder.key,
    t.select.parameters.file.key,
    t.select.parameters.number.key,
  ];
  String outputPath = format;
  for (final parameter in parameters) {
    final value = ref.read(parameterProvider(parameter));
    outputPath = outputPath.replaceAll('{{$parameter}}', value);
  }

  // Replace the status placeholder with the actual status
  final statusReplacement = switch (status) {
    Status.marked || Status.keptUnmarked => status.name,
    _ => '<${Status.marked.name}|${Status.keptUnmarked.name}>',
  };
  outputPath = outputPath.replaceAll('{{status}}', statusReplacement);
  outputPath = join(config.outputPath!, '$outputPath.jpg');
  // If the status is not marked or unmarked, we can return the output path
  // immediately, as the directory structure is not needed
  if (status != Status.marked && status != Status.keptUnmarked) {
    return outputPath;
  }

  // Otherwise, create the output directory if it does not exist
  final outputDirectory = dirname(outputPath);
  if (!Directory(outputDirectory).existsSync()) {
    Directory(outputDirectory).createSync(recursive: true);
  }
  return outputPath;
}
