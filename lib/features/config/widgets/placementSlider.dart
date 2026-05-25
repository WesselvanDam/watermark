import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/config.dart';
import '../../core/providers/configuration.dart';

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
    final percentageValue = value * 100;
    return Slider(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      max: 100,
      divisions: 100,
      value: percentageValue,
      label: '${percentageValue.round()}%',
      onChanged: (sliderValue) => onChanged(sliderValue / 100),
    );
  }
}
