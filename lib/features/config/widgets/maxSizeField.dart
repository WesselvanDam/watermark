import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/config.dart';
import '../../core/providers/configuration.dart';

class MaxSizeField extends ConsumerStatefulWidget {
  const MaxSizeField({
    required this.configValue,
    required this.onChanged,
    required this.placeholder,
    super.key,
  });

  final int? Function(Config config) configValue;
  final void Function(WidgetRef ref, int? value) onChanged;
  final String placeholder;

  @override
  ConsumerState<MaxSizeField> createState() => _MaxSizeFieldState();
}

class _MaxSizeFieldState extends ConsumerState<MaxSizeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _valueToText(widget.configValue(ref.read(configurationProvider))),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configValue = widget.configValue(ref.watch(configurationProvider));
    final textValue = _valueToText(configValue);

    if (_controller.text != textValue) {
      _controller.text = textValue;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(hintText: widget.placeholder),
      onChanged: (value) {
        widget.onChanged(ref, value.isEmpty ? null : int.tryParse(value));
      },
    );
  }

  String _valueToText(int? value) {
    return value?.toString() ?? '';
  }
}
