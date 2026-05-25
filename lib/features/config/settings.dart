import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../../widgets/input_row.dart';
import '../../widgets/panel_header.dart';
import '../core/providers/configuration.dart';
import '../core/providers/parameters.dart';
import '../core/providers/prefs.dart';
import 'widgets/explorerField.dart';
import 'widgets/filenameFormat.dart';
import 'widgets/maxSizeField.dart';
import 'widgets/placementSlider.dart';

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
    final textStyle = Theme.of(context).textTheme.labelLarge;

    return [
      Text(t.config.input.heading.toUpperCase(), style: textStyle),
      const Divider(),
      InputRow(
        label: t.config.input.source.heading,
        info: t.config.input.source.info,
        child: ExplorerField(
          pickFolder: true,
          onPathSelected: (value) {
            // Update the config with the new input path
            ref
                .read(configurationProvider.notifier)
                .update((state) => state.copyWith(inputPath: value));
            // Reset the number parameter
            ref.invalidate(parameterProvider('number'));
          },
          displayCallback: (config) =>
              config.inputPath ?? t.config.input.source.placeholder,
        ),
      ),
      InputRow(
        label: t.config.input.watermark.heading,
        info: t.config.input.watermark.info,
        child: ExplorerField(
          pickFolder: false,
          onPathSelected: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkPath: value)),
          displayCallback: (config) =>
              config.watermarkPath ?? t.config.input.watermark.placeholder,
        ),
      ),
      const SizedBox(height: 32.0),
      Text(t.config.output.heading.toUpperCase(), style: textStyle),
      const Divider(),
      InputRow(
        label: t.config.output.destination.heading,
        info: t.config.output.destination.info,
        child: ExplorerField(
          pickFolder: true,
          onPathSelected: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(outputPath: value)),
          displayCallback: (config) =>
              config.outputPath ?? t.config.output.destination.placeholder,
        ),
      ),
      InputRow(
        label: t.config.output.filenameFormat.heading,
        info: t.config.output.filenameFormat.info,
        child: const FilenameFormat(),
      ),
      InputRow(
        label: t.config.output.originalMaxSize.heading,
        info: t.config.output.originalMaxSize.info,
        child: MaxSizeField(
          configValue: (config) => config.originalMaxSize,
          onChanged: (ref, value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(originalMaxSize: value)),
          placeholder: t.config.output.originalMaxSize.placeholder,
        ),
      ),
      InputRow(
        label: t.config.output.watermarkedMaxSize.heading,
        info: t.config.output.watermarkedMaxSize.info,
        child: MaxSizeField(
          configValue: (config) => config.watermarkedMaxSize,
          onChanged: (ref, value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkedMaxSize: value)),
          placeholder: t.config.output.watermarkedMaxSize.placeholder,
        ),
      ),
      const SizedBox(height: 32.0),
      Text(t.config.placement.heading.toUpperCase(), style: textStyle),
      const Divider(),
      InputRow(
        label: t.config.placement.anchorPoint.heading,
        info: t.config.placement.anchorPoint.info,
        child: Builder(
          builder: (context) {
            final cfg = ref.watch(configurationProvider);
            final anchorX = cfg.watermarkAnchorX;
            final anchorY = cfg.watermarkAnchorY;

            Widget buttonFor(int col, int row) {
              final x = col / 2.0; // 0, 0.5, 1
              final y = row / 2.0;
              final selected = anchorX == x && anchorY == y;
              return Padding(
                padding: const EdgeInsets.all(2),
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
      ),
      InputRow(
        label: t.config.placement.leftFraction.heading,
        info: t.config.placement.leftFraction.info,
        child: PlacementSlider(
          displayCallback: (config) => config.watermarkLeftFraction,
          onChanged: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkLeftFraction: value)),
        ),
      ),
      InputRow(
        label: t.config.placement.topFraction.heading,
        info: t.config.placement.topFraction.info,
        child: PlacementSlider(
          displayCallback: (config) => config.watermarkTopFraction,
          onChanged: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkTopFraction: value)),
        ),
      ),
      InputRow(
        label: t.config.placement.widthFraction.heading,
        info: t.config.placement.widthFraction.info,
        child: PlacementSlider(
          displayCallback: (config) => config.watermarkWidthFraction,
          onChanged: (value) => ref
              .read(configurationProvider.notifier)
              .update((state) => state.copyWith(watermarkWidthFraction: value)),
        ),
      ),
      const SizedBox(height: 16.0),
      Consumer(
        builder: (context, ref, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => storeConfig(ref),
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
}
