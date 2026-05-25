import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../../utils/photo_queue_state.dart';
import '../../../utils/placement.dart';
import '../../../widgets/panel_header.dart';
import '../../core/providers/configuration.dart';
import '../../core/providers/placement_validation.dart';
import '../../core/providers/photos.dart';
import '../../core/providers/shortcuts.dart';
import '../../../utils/processPhoto.dart';
import '../../../utils/status.dart';
import '../../photo/photoIndex.dart';
import 'local_widgets/preview.dart';

class Workspace extends ConsumerWidget {
  const Workspace({super.key});

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
              PanelHeader(
                title: t.workspace.heading,
                icon: Icons.photo_library_outlined,
              ),
              const SizedBox(height: 16.0),
              if (useScrollable)
                SizedBox(height: 360.0, child: preview)
              else
                Expanded(child: preview),
              const SizedBox(height: 12.0),
              Row(
                spacing: 16.0,
                children: [
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => handler(Status.none, -1),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(t.workspace.actions.previous),
                  ),
                  Column(
                    spacing: 8.0,
                    children: [
                      FilledButton.icon(
                        onPressed: () => handler(Status.marked, 1),
                        icon: const Icon(Icons.arrow_upward),
                        label: Text(t.workspace.actions.mark),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => handler(Status.keptUnmarked, 1),
                        icon: const Icon(Icons.arrow_downward),
                        label: Text(t.workspace.actions.dontMark),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => handler(Status.skipped, 1),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(t.workspace.actions.skip),
                  ),
                  const Spacer(),
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

