import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../../providers/configuration.dart';
import '../../../providers/parameters.dart';
import '../../../providers/photos.dart';
import '../../../providers/shortcuts.dart';
import '../../../utils/generateOutputPath.dart';
import '../../../utils/processPhoto.dart';
import '../../../utils/status.dart';
import '../photoIndex.dart';
import 'local_widgets/parameter.dart';
import 'local_widgets/preview.dart';

class Select extends ConsumerWidget {
  const Select({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(photoIndexProvider.select((value) => value));
    final photo = ref.watch(
      photosProvider.select((value) => value.isEmpty ? null : value[index]),
    );
    debugPrint('Index: $index. Photo: $photo');

    if (photo == null) {
      return const SizedBox();
    }

    Future<void> handler(Status status, int change) =>
        processAction(context, ref, photo, index, status, change);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.select.heading,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Flexible(
                  child: ParameterTextField(
                    name: t.select.parameters.folder.key,
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: ParameterTextField(
                    name: t.select.parameters.file.key,
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: ParameterTextField(
                    name: t.select.parameters.number.key,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  t.progress(
                    current: index + 1,
                    total: ref.read(photosProvider).length,
                  ),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: LinearProgressIndicator(
                    value: index / (ref.read(photosProvider).length - 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: SelectableText(
                photo.original.path,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: SizedBox(
                height: 480,
                child: Center(
                  child: ImagePreview(
                    image: photo.original,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Chip(
                label: Text('Status: ${photo.status.name}'),
                backgroundColor: {
                  Status.none:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  Status.skipped:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  Status.keptUnmarked:
                      Theme.of(context).colorScheme.secondaryContainer,
                  Status.marked: Theme.of(context).colorScheme.primaryContainer,
                }[photo.status],
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  ref.watch(
                    configurationProvider
                        .select((value) => value.outputFileNameFormat),
                  );
                  // Also watch all the parameterProviders
                  ref.watch(parameterProvider(t.select.parameters.folder.key));
                  ref.watch(parameterProvider(t.select.parameters.file.key));
                  ref.watch(parameterProvider(t.select.parameters.number.key));
                  return SelectableText(
                    '${t.config.output.destination.heading}: ${generateOutputPath(ref, status: Status.none)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
            ),
            ButtonBar(
              overflowButtonSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => handler(Status.none, -1),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(t.select.actions.previous),
                ),
                OutlinedButton.icon(
                  onPressed: () => handler(Status.skipped, 1),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(t.select.actions.skip),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => handler(Status.keptUnmarked, 1),
                  icon: const Icon(Icons.arrow_downward),
                  label: Text(t.select.actions.dontMark),
                ),
                FilledButton.icon(
                  onPressed: ref.watch(
                    configurationProvider.select(
                      (value) => value.watermarkPath == null,
                    ),
                  )
                      ? null
                      : () => handler(Status.marked, 1),
                  icon: const Icon(Icons.arrow_upward),
                  label: Text(t.select.actions.mark),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Consumer(
              builder: (context, ref, child) {
                return CheckboxListTile(
                  title: Text(t.shortcuts),
                  subtitle: Text(t.shortcutsDescription),
                  value: ref.watch(shortcutsProvider),
                  onChanged: (value) =>
                      ref.read(shortcutsProvider.notifier).update(value!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
