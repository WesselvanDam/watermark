import 'package:flutter/material.dart';

class PanelHeader extends StatelessWidget {
  const PanelHeader({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: textTheme.titleMedium)],
        ),
      ],
    );
  }
}
