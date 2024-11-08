import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/config.dart';
import '../../../../providers/configuration.dart';

class ExplorerField extends ConsumerStatefulWidget {
  const ExplorerField({
    required this.pickFolder,
    required this.onPathSelected,
    required this.displayCallback,
    super.key,
  });

  final bool pickFolder;
  final Function(String?) onPathSelected;
  final ConfigTransformCallback<String> displayCallback;

  @override
  ConsumerState<ExplorerField> createState() => _ExplorerFieldState();
}

class _ExplorerFieldState extends ConsumerState<ExplorerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.displayCallback(ref.read(configurationProvider)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final path = await _selectPath(context, ref);
        widget.onPathSelected(path);
        _controller.text = path ?? '';
      },
      child: AbsorbPointer(
        child: TextField(
          readOnly: true,
          controller: _controller,
        ),
      ),
    );
  }

  Future<String?> _selectPath(BuildContext context, WidgetRef ref) async {
    // Show the file picker
    return widget.pickFolder
        ? await FilePicker.platform.getDirectoryPath()
        : await FilePicker.platform
            .pickFiles()
            .then((value) => value?.files.single.path);
  }
}
