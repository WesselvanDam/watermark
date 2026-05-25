import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../../utils/output_template.dart';
import '../../core/providers/configuration.dart';
import '../../core/providers/filename_format_validation.dart';

class FilenameFormat extends ConsumerStatefulWidget {
  const FilenameFormat({super.key});

  @override
  ConsumerState<FilenameFormat> createState() => _FilenameFormatState();
}

class _FilenameFormatState extends ConsumerState<FilenameFormat> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _TemplateTextEditingController();
    _controller.text =
        ref.read(configurationProvider).outputFileNameFormat ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = ref.watch(
      configurationProvider.select((value) => value.outputFileNameFormat),
    );
    final validation = ref.watch(filenameFormatValidationProvider);

    if (_controller.text != (format ?? '')) {
      _controller.text = format ?? '';
    }

    return TextField(
      controller: _controller,
      maxLines: null,
      decoration: InputDecoration(
        hintText: t.config.output.filenameFormat.placeholder,
        errorText: validation.message,
      ),
      onChanged: (value) => ref
          .read(configurationProvider.notifier)
          .update((state) => state.copyWith(outputFileNameFormat: value)),
    );
  }
}

class _TemplateTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final colorScheme = Theme.of(context).colorScheme;
    return buildOutputTemplateTextSpan(
      text,
      baseStyle: baseStyle,
      placeholderStyles: {
        'folder': baseStyle.copyWith(color: colorScheme.primary),
        'filename': baseStyle.copyWith(color: colorScheme.secondary),
        'number': baseStyle.copyWith(color: colorScheme.tertiary),
        'status': baseStyle.copyWith(color: colorScheme.error),
        'original': baseStyle.copyWith(color: Colors.teal),
      },
      values: {
        'folder': '{folder}',
        'filename': '{filename}',
        'number': '{number}',
        'status': '{status}',
        'original': '{original}',
      },
      invalidPlaceholderStyle: baseStyle.copyWith(color: colorScheme.error),
    );
  }
}
