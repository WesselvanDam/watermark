import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../../utils/placement.dart';
import '../../widgets/panel_header.dart';
import '../core/providers/configuration.dart';
import '../core/providers/filename_format_validation.dart';
import '../core/providers/placement_validation.dart';
import '../core/providers/prefs.dart';
import 'local_widgets/explorerField.dart';
import 'local_widgets/filenameFormat.dart';
import 'local_widgets/placementSlider.dart';

class Settings extends ConsumerWidget {
  const Settings({this.asPanel = false, super.key});

  final bool asPanel;

  /// Opens the explorer and allows the user to select a folder that contains
  /// the images to be processed.
  Future<String?> selectFolder(WidgetRef ref) async {
    return FilePicker.platform.getDirectoryPath();
  }

  /// Opens the explorer and allows the user to select a watermark image.
  Future<void> selectWatermark(WidgetRef ref) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      final path = result.files.single.path;
      ref
          .read(configurationProvider.notifier)
          .update((state) => state.copyWith(watermarkPath: path));
    }
  }

  Future<void> storeConfig(WidgetRef ref) async {
    final config = ref.read(configurationProvider);
    final json = config.toJson();
    final prefs = ref.read(prefsProvider);
    await prefs.setString('config', jsonEncode(json));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = _buildContent(context, ref);
    if (asPanel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeader(title: t.config.heading, icon: Icons.settings),
          const SizedBox(height: 16.0),
          ...content,
        ],
      );
    }

    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(
        t.config.heading,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      children: content,
    );
  }

  List<Widget> _buildContent(BuildContext context, WidgetRef ref) {
    return [
      heading(context, t.config.input.heading),
      const Divider(),
      row(
        context,
        t.config.input.source.heading,
        ExplorerField(
          pickFolder: true,
          onPathSelected: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(inputPath: value)),
          displayCallback: (config) =>
              config.inputPath ?? t.config.input.source.placeholder,
        ),
        t.config.input.source.info,
      ),
      row(
        context,
        t.config.input.watermark.heading,
        ExplorerField(
          pickFolder: false,
          onPathSelected: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkPath: value)),
          displayCallback: (config) =>
              config.watermarkPath ?? t.config.input.watermark.placeholder,
        ),
        t.config.input.watermark.info,
      ),
      const SizedBox(height: 32.0),
      heading(context, t.config.output.heading),
      const Divider(),
      row(
        context,
        t.config.output.destination.heading,
        ExplorerField(
          pickFolder: true,
          onPathSelected: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(outputPath: value)),
          displayCallback: (config) =>
              config.outputPath ?? t.config.output.destination.placeholder,
        ),
        t.config.output.destination.info,
      ),
      row(
        context,
        t.config.output.filenameFormat.heading,
        const FilenameFormat(),
        t.config.output.filenameFormat.info,
      ),
      const SizedBox(height: 32.0),
      heading(context, t.config.placement.heading),
      const Divider(),
      row(
        context,
        t.config.placement.anchorPoint.heading,
        Builder(
          builder: (context) {
            final cfg = ref.watch(configurationProvider);
            final anchorX = cfg.watermarkAnchorX;
            final anchorY = cfg.watermarkAnchorY;

            Widget buttonFor(int col, int row) {
              final x = col / 2.0; // 0, 0.5, 1
              final y = row / 2.0;
              final selected = anchorX == x && anchorY == y;
              return Padding(
                padding: const EdgeInsets.all(0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => ref
                      .read(configurationProvider.notifier)
                      .update(
                        (state) => state.copyWith(
                          watermarkAnchorX: x,
                          watermarkAnchorY: y,
                        ),
                      ),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: selected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            return Row(
              children: [
                for (var r = 0; r < 3; r++)
                  Column(
                    children: [for (var c = 0; c < 3; c++) buttonFor(r, c)],
                  ),
              ],
            );
          },
        ),
        t.config.placement.anchorPoint.info,
      ),
      row(
        context,
        t.config.placement.leftFraction.heading,
        PlacementSlider(
          displayCallback: (config) => config.watermarkLeftFraction,
          onChanged: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkLeftFraction: value)),
        ),
        t.config.placement.leftFraction.info,
      ),
      row(
        context,
        t.config.placement.topFraction.heading,
        PlacementSlider(
          displayCallback: (config) => config.watermarkTopFraction,
          onChanged: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkTopFraction: value)),
        ),
        t.config.placement.topFraction.info,
      ),
      row(
        context,
        t.config.placement.widthFraction.heading,
        PlacementSlider(
          displayCallback: (config) => config.watermarkWidthFraction,
          onChanged: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkWidthFraction: value)),
        ),
        t.config.placement.widthFraction.info,
      ),
      const SizedBox(height: 16.0),
      Consumer(
        builder: (context, ref, child) {
          final validation = ref.watch(placementValidationProvider);
          final filenameValidation = ref.watch(
            filenameFormatValidationProvider,
          );
          final isValid =
              validation.isValid ||
              validation.status == PlacementValidationStatus.unavailable;
          final canSave = isValid && filenameValidation.isValid;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: canSave ? () => storeConfig(ref) : null,
                  icon: const Icon(Icons.save),
                  label: Text(t.save),
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 16.0),
    ];
  }

  Widget heading(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      text.toUpperCase(),
      style: textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget row(BuildContext context, String label, Widget child, String info) {
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
