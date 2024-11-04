import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/parameters.dart';

class ParameterTextField extends ConsumerStatefulWidget {
  const ParameterTextField({required this.name, super.key});

  final String name;

  @override
  ConsumerState<ParameterTextField> createState() => _ParameterState();
}

class _ParameterState extends ConsumerState<ParameterTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(parameterProvider(widget.name)));
  }

  @override
  Widget build(BuildContext context) {
    // Update the controller when the parameter changes
    ref.listen<String>(
      parameterProvider(widget.name),
      (prev, next) {
        if (_controller.text != next) {
          _controller.text = next;
        }
      },
    );
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.name,
      ),
      onChanged: (value) {
        ref.read(parameterProvider(widget.name).notifier).update((_) => value);
      },
    );
  }
}
