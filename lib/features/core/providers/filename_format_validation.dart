import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/output_template.dart';
import 'configuration.dart';

enum FilenameFormatValidationStatus { valid, invalid, unavailable }

class FilenameFormatValidationResult {
  const FilenameFormatValidationResult._({
    required this.status,
    required this.message,
    required this.analysis,
  });

  const FilenameFormatValidationResult.valid(OutputTemplateAnalysis analysis)
    : this._(
        status: FilenameFormatValidationStatus.valid,
        message: null,
        analysis: analysis,
      );

  const FilenameFormatValidationResult.invalid({
    required String message,
    required OutputTemplateAnalysis analysis,
  }) : this._(
         status: FilenameFormatValidationStatus.invalid,
         message: message,
         analysis: analysis,
       );

  const FilenameFormatValidationResult.unavailable(String message)
    : this._(
        status: FilenameFormatValidationStatus.unavailable,
        message: message,
        analysis: const OutputTemplateAnalysis(segments: [], issues: []),
      );

  final FilenameFormatValidationStatus status;
  final String? message;
  final OutputTemplateAnalysis analysis;

  bool get isValid => status == FilenameFormatValidationStatus.valid;
}

final filenameFormatValidationProvider =
    Provider<FilenameFormatValidationResult>((ref) {
      final format = ref.watch(
        configurationProvider.select((value) => value.outputFileNameFormat),
      );
      if (format == null || format.trim().isEmpty) {
        return const FilenameFormatValidationResult.unavailable(
          'Set a filename format before saving configuration.',
        );
      }

      final analysis = analyzeOutputTemplate(format);
      if (!analysis.isValid) {
        return FilenameFormatValidationResult.invalid(
          message: analysis.message ?? 'Invalid filename format.',
          analysis: analysis,
        );
      }

      return FilenameFormatValidationResult.valid(analysis);
    });
