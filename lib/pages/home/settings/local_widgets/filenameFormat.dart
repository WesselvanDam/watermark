import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../i18n/strings.g.dart';
import '../../../../providers/configuration.dart';

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
    _controller = TextEditingController(
      text: ref.read(configurationProvider).outputFileNameFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: t.config.output.filenameFormat.placeholder,
      ),
      controller: _controller,
      onChanged: (value) {
        debugPrint('Filename format changed to: $value');
        ref.read(configurationProvider.notifier).update(
              (state) => state.copyWith(outputFileNameFormat: value),
            );
      },
    );
  }
}
