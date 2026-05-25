import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../../features/core/providers/parameters.dart';

class FilenameFormat extends ConsumerStatefulWidget {
  const FilenameFormat({super.key});

  @override
  ConsumerState<FilenameFormat> createState() => _FilenameFormatState();
}

class _FilenameFormatState extends ConsumerState<FilenameFormat> {
  @override
  Widget build(BuildContext context) {
    final param = ref.watch(parameterProvider(t.workspace.parameters.file.key));
    return TextField(
      controller: TextEditingController(text: param),
      onChanged: (value) => ref
          .read(parameterProvider(t.workspace.parameters.file.key).notifier)
          .update((_) => value),
    );
  }
}
