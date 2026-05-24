import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/config.dart';
import '../../../features/core/providers/configuration.dart';

class PlacementSlider extends ConsumerWidget {
  const PlacementSlider({
    required this.displayCallback,
    required this.onChanged,
    super.key,
  });

  final ConfigTransformCallback<double> displayCallback;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = displayCallback(ref.read(configurationProvider));
    return Slider(value: value, onChanged: onChanged);
  }
}
