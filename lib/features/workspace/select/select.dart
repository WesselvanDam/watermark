import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../core/providers/configuration.dart';
import '../../core/providers/parameters.dart';
import '../../core/providers/photos.dart';
import '../../core/providers/shortcuts.dart';
import '../../../utils/generateOutputPath.dart';
import '../../../utils/processPhoto.dart';
import '../../../utils/status.dart';
import '../../photo/photoIndex.dart';
import 'local_widgets/parameter.dart';
import 'local_widgets/preview.dart';

class Select extends ConsumerWidget {
  const Select({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(photoIndexProvider.select((value) => value));
    final total = ref.watch(photosProvider.select((value) => value.length));
    final photo = ref.watch(
      photosProvider.select((value) {
        if (value.isEmpty || index < 0 || index >= value.length) {
          return null;
        }
        return value[index];
      }),
    );
    debugPrint('Index: $index. Photo: $photo');

    if (photo == null) {
      return const SizedBox();
    }

    Future<void> handler(Status status, int change) =>
        processAction(context, ref, photo, index, status, change);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final useScrollable =
            !constraints.hasBoundedHeight || constraints.maxHeight < 720;
        final fieldWidth = isCompact && constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 200.0;
        final progressValue = total <= 1 ? 0.0 : index / (total - 1);
        final preview = DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Center(child: ImagePreview(image: photo.original)),
        );

        final content = Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: useScrollable ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Text(
                t.select.heading,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: ParameterTextField(
                      name: t.select.parameters.folder.key,
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: ParameterTextField(
                      name: t.select.parameters.file.key,
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: ParameterTextField(
                      name: t.select.parameters.number.key,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text(
                    t.progress(current: index + 1, total: total),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: LinearProgressIndicator(value: progressValue),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Center(
                child: SelectableText(
                  photo.original.path,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 12.0),
              if (useScrollable)
                SizedBox(height: 360.0, child: preview)
              else
                Expanded(child: preview),
              const SizedBox(height: 12.0),
              Center(
                child: Chip(
                  label: Text('Status: ${photo.status.name}'),
                  backgroundColor: {
                    Status.none: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
                    Status.skipped: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    Status.keptUnmarked: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    Status.marked: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  }[photo.status],
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    ref.watch(
                      configurationProvider.select(
                        (value) => value.outputFileNameFormat,
                      ),
                    );
                    ref.watch(
                      parameterProvider(t.select.parameters.folder.key),
                    );
                    ref.watch(parameterProvider(t.select.parameters.file.key));
                    ref.watch(
                      parameterProvider(t.select.parameters.number.key),
                    );
                    return SelectableText(
                      '${t.config.output.destination.heading}: ${generateOutputPath(ref, status: Status.none)}',
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              OverflowBar(
                spacing: 8.0,
                overflowSpacing: 8.0,
                alignment: MainAxisAlignment.center,
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
                    onPressed:
                        ref.watch(
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
              const SizedBox(height: 8.0),
              Consumer(
                builder: (context, ref, child) {
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
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
        );

        if (useScrollable) {
          return SingleChildScrollView(child: content);
        }

        return content;
      },
    );
  }
}
