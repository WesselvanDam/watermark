import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../../providers/configuration.dart';
import '../../../providers/prefs.dart';
import 'local_widgets/explorerField.dart';
import 'local_widgets/filenameFormat.dart';
import 'local_widgets/placementSlider.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

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
      ref.read(configurationProvider.notifier).update(
            (state) => state.copyWith(watermarkPath: path),
          );
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
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(
        t.config.heading,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      children: [
        heading(context, t.config.input.heading),
        const Divider(),
        row(
          context,
          t.config.input.source.heading,
          ExplorerField(
            pickFolder: true,
            onPathSelected: (value) =>
                ref.read(configurationProvider.notifier).update(
                      (state) => state.copyWith(inputPath: value),
                    ),
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
            onPathSelected: (value) =>
                ref.read(configurationProvider.notifier).update(
                      (state) => state.copyWith(watermarkPath: value),
                    ),
            displayCallback: (config) =>
                config.watermarkPath ?? t.config.input.watermark.placeholder,
          ),
          t.config.input.watermark.info,
        ),
        const SizedBox(height: 16.0),
        heading(context, t.config.output.heading),
        const Divider(),
        row(
          context,
          t.config.output.destination.heading,
          ExplorerField(
            pickFolder: true,
            onPathSelected: (value) =>
                ref.read(configurationProvider.notifier).update(
                      (state) => state.copyWith(outputPath: value),
                    ),
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
        const SizedBox(height: 16.0),
        heading(context, t.config.placement.heading),
        const Divider(),
        row(
          context,
          t.config.placement.leftFraction.heading,
          PlacementSlider(
            displayCallback: (config) => config.watermarkLeftFraction,
            onChanged: (value) =>
                ref.read(configurationProvider.notifier).update(
                      (state) => state.copyWith(watermarkLeftFraction: value),
                    ),
          ),
          t.config.placement.leftFraction.info,
        ),
        row(
          context,
          t.config.placement.topFraction.heading,
          PlacementSlider(
            displayCallback: (config) => config.watermarkTopFraction,
            onChanged: (value) =>
                ref.read(configurationProvider.notifier).update(
                      (state) => state.copyWith(watermarkTopFraction: value),
                    ),
          ),
          t.config.placement.topFraction.info,
        ),
        row(
          context,
          t.config.placement.widthFraction.heading,
          PlacementSlider(
            displayCallback: (config) => config.watermarkWidthFraction,
            onChanged: (value) =>
                ref.read(configurationProvider.notifier).update(
                      (state) => state.copyWith(watermarkWidthFraction: value),
                    ),
          ),
          t.config.placement.widthFraction.info,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => storeConfig(ref),
            icon: const Icon(Icons.save),
            label: Text(t.save),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget heading(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget row(BuildContext context, String label, Widget child, String info) {
    return Row(
      children: [
        Tooltip(
          message: info,
          textStyle: Theme.of(context).tooltipTheme.textStyle?.copyWith(
                fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
              ),
          margin: const EdgeInsets.symmetric(horizontal: 48.0),
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        Flexible(child: child),
      ],
    );
  }
}
