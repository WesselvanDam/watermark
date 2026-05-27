import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../i18n/strings.g.dart';
import '../../../../utils/status.dart';
import '../../../core/providers/configuration.dart';
import '../../../core/providers/photos.dart';
import '../../../core/providers/placement_validation.dart';

class WorkspaceActionButtons extends ConsumerWidget {
  const WorkspaceActionButtons({
    required this.index,
    required this.onAction,
    super.key,
  });

  final int index;
  final Future<void> Function(Status status, int change) onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(photosProvider.select((value) => value.length));
    final outputPath = ref.watch(
      configurationProvider.select((value) => value.outputPath),
    );
    final watermarkPath = ref.watch(
      configurationProvider.select((value) => value.watermarkPath),
    );
    final placementValid = ref.watch(
      placementValidationProvider.select((value) => value.isValid),
    );

    final inRange = total > 0 && index >= 0 && index < total;
    final hasOutput = _hasPath(outputPath);
    final hasWatermark = _hasPath(watermarkPath);

    final canPrevious = inRange && index > 0;
    final canSkip = inRange && index < total - 1;
    final canMark = inRange && hasOutput && hasWatermark && placementValid;
    final canDontMark = inRange && hasOutput;

    final scheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 16.0,
      children: [
        const Spacer(),
        _KeycapButton.neutral(
          icon: Icons.arrow_back,
          label: Text(t.workspace.actions.previous),
          onPressed: canPrevious ? () => onAction(Status.none, -1) : null,
          scheme: scheme,
        ),
        Column(
          spacing: 8.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            _KeycapButton.mark(
              label: Text(t.workspace.actions.mark),
              onPressed: canMark ? () => onAction(Status.marked, 1) : null,
              scheme: scheme,
            ),
            _KeycapButton.dontMark(
              label: Text(t.workspace.actions.dontMark),
              onPressed: canDontMark
                  ? () => onAction(Status.keptUnmarked, 1)
                  : null,
              scheme: scheme,
            ),
          ],
        ),
        _KeycapButton.neutral(
          icon: Icons.arrow_forward,
          label: Text(t.workspace.actions.skip),
          onPressed: canSkip ? () => onAction(Status.skipped, 1) : null,
          scheme: scheme,
        ),
        const Spacer(),
      ],
    );
  }
}

class _KeycapButton extends StatelessWidget {
  const _KeycapButton({
    required this.style,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  factory _KeycapButton.mark({
    required Widget label,
    required VoidCallback? onPressed,
    required ColorScheme scheme,
  }) {
    return _KeycapButton(
      style: _keycapStyle(
        background: scheme.primary,
        foreground: scheme.onPrimary,
        disabledBackground: scheme.surfaceContainerLow,
        disabledForeground: scheme.onSurfaceVariant,
        borderColor: scheme.primaryFixedDim,
        shadowColor: scheme.shadow,
      ),
      icon: Icons.arrow_upward,
      label: label,
      onPressed: onPressed,
    );
  }

  factory _KeycapButton.dontMark({
    required Widget label,
    required VoidCallback? onPressed,
    required ColorScheme scheme,
  }) {
    return _KeycapButton(
      style: _keycapStyle(
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
        disabledBackground: scheme.surfaceContainerLow,
        disabledForeground: scheme.onSurfaceVariant,
        borderColor: scheme.secondaryFixedDim,
        shadowColor: scheme.shadow,
      ),
      icon: Icons.arrow_downward,
      label: label,
      onPressed: onPressed,
    );
  }

  factory _KeycapButton.neutral({
    required Widget label,
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme scheme,
  }) {
    return _KeycapButton(
      style: _keycapStyle(
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurface,
        disabledBackground: scheme.surfaceContainerLow,
        disabledForeground: scheme.onSurfaceVariant,
        borderColor: scheme.outlineVariant,
        shadowColor: scheme.shadow,
      ),
      icon: icon,
      label: label,
      onPressed: onPressed,
    );
  }

  final ButtonStyle style;
  final IconData icon;
  final Widget label;
  final VoidCallback? onPressed;

  static ButtonStyle _keycapStyle({
    required Color background,
    required Color foreground,
    required Color disabledBackground,
    required Color disabledForeground,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return ButtonStyle(
      fixedSize: WidgetStateProperty.all(const Size(152.0, 52.0)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12.0),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? disabledBackground
            : background,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? disabledForeground
            : foreground,
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? borderColor.withOpacity(0.4)
              : borderColor,
        ),
      ),
      elevation: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? 0.0 : 2.0,
      ),
      shadowColor: WidgetStateProperty.all(shadowColor.withOpacity(0.25)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tooltipMessage = {
      Icons.arrow_back: 'Previous action unavailable. No previous image.',
      Icons.arrow_forward: 'Next action unavailable. No next image.',
      Icons.arrow_upward: 'Marking unavailable. Ensure output and watermark paths are set and placement is valid.',
      Icons.arrow_downward: 'Keeping without marking unavailable. Ensure output path is set.',
    };
    return TooltipVisibility(
      visible: onPressed == null,
      child: Tooltip(
        message: tooltipMessage[icon] ?? 'Action unavailable. Ensure your configuration is valid',
        child: FilledButton.icon(
          style: style,
          onPressed: onPressed,
          icon: Icon(icon, size: 18.0),
          label: label,
        ),
      ),
    );
  }
}

bool _hasPath(String? path) {
  return path != null && path.trim().isNotEmpty;
}
