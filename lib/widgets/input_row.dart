import 'package:flutter/material.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    required this.label,
    required this.child,
    required this.info,
    super.key,
  });

  final String label;
  final Widget child;
  final String info;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelStyle = Theme.of(context).textTheme.labelSmall;
        final labelWidget = Row(
          children: [
            Text(label.toUpperCase(), style: labelStyle),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 16),
              onPressed: null,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: info,
            ),
          ],
        );

        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [labelWidget, child],
          );
        }

        return Row(
          children: [
            SizedBox(width: 140, child: labelWidget),
            const SizedBox(width: 8.0),
            Flexible(child: child),
          ],
        );
      },
    );
  }
}
