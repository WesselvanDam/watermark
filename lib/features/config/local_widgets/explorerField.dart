import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/config.dart';
import '../../../features/core/providers/configuration.dart';

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

    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            readOnly: true,
          ),
        ),
        const SizedBox(width: 8.0),
        OutlinedButton(
          onPressed: () async {
            final path = await _selectPath(context, ref);
            if (path == null) return;

            widget.onPathSelected(path);
            _controller.text = path;
          },
          child: const Text('Browse'),
        ),
      ],
    );
  }

  Future<String?> _selectPath(BuildContext context, WidgetRef ref) async {
    // Show the file picker
    return widget.pickFolder
        ? await FilePicker.platform.getDirectoryPath()
        : await FilePicker.platform.pickFiles().then(
            (value) => value?.files.single.path,
          );
  }
}
