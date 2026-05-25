
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../i18n/strings.g.dart';
import '../../models/photo.dart';
import '../../utils/output_template.dart';
import '../../utils/photo_queue_state.dart';
import '../../utils/status.dart';
import '../../widgets/panel_header.dart';
import '../core/providers/configuration.dart';
import '../core/providers/parameters.dart';
import '../core/providers/photos.dart';
import '../photo/photoIndex.dart';
import 'widgets/parameter.dart';

const int _recentQueueLimit = 5;

String _formatTakenAt(DateTime? date) {
  if (date == null) {
    return '---';
  }
  return DateFormat('yyyy-MM-dd HH:mm').format(date);
}

_StatusPresentation _statusPresentation(Status status, ColorScheme scheme) {
  return switch (status) {
    Status.marked => _StatusPresentation(
      label: 'Marked',
      icon: Icons.bookmark,
      color: scheme.primary,
    ),
    Status.keptUnmarked => _StatusPresentation(
      label: 'Original',
      icon: Icons.check_circle,
      color: scheme.secondary,
    ),
    Status.skipped => _StatusPresentation(
      label: 'Skipped',
      icon: Icons.block,
      color: scheme.tertiary,
    ),
    Status.none => _StatusPresentation(
      label: 'Pending',
      icon: Icons.schedule,
      color: scheme.outline,
    ),
  };
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _QueueEntry {
  const _QueueEntry({required this.path, required this.status});

  final String path;
  final Status status;
}

List<_QueueEntry> _recentQueue(List<Photo> photos, int currentIndex) {
  final items = <_QueueEntry>[];
  for (
    var i = currentIndex - 1;
    i >= 0 && items.length < _recentQueueLimit;
    i--
  ) {
    final photo = photos[i];
    if (photo.status == Status.none) {
      continue;
    }
    items.add(_QueueEntry(path: photo.original.path, status: photo.status));
  }
  return items;
}

class InspectorPanel extends ConsumerWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider);
    final index = ref.watch(photoIndexProvider);
    final hasPhoto = index >= 0 && index < photos.length;
    final photo = hasPhoto ? photos[index] : null;
    final recentItems = _recentQueue(photos, index);
    final total = photos.length;
    final current = hasPhoto ? index + 1 : 0;
    final progress = total == 0 ? 0.0 : current / total;

    final isAllProcessed = ref.watch(
      photosProvider.select((photos) => allPhotosProcessed(photos)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PanelHeader(title: 'Details', icon: Icons.data_object),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              _Section(
                title: 'Metadata',
                child: photo == null
                    ? const _EmptyState(message: 'No photo selected.')
                    : _MetadataRows(photo: photo),
              ),
              const SizedBox(height: 16.0),
              const _Section(
                title: 'Output Parameters',
                child: _ParameterEditors(),
              ),
              const SizedBox(height: 16.0),
              const _Section(
                title: 'Output Preview',
                child: _OutputDestinationPreview(),
              ),
              const SizedBox(height: 16.0),
              _Section(
                title: 'Recent Queue',
                child: recentItems.isEmpty
                    ? const _EmptyState(message: 'No processed items yet.')
                    : Column(
                        children: [
                          for (final entry in recentItems)
                            _RecentQueueItem(entry: entry),
                        ],
                      ),
              ),
            ],
          ),
        ),
        if (isAllProcessed)
           AllProcessedMessage(completionMessage: t.workspace.allProcessed),
        _ProgressSection(current: current, total: total, progress: progress),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.labelLarge),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }
}

class _MetadataRows extends StatelessWidget {
  const _MetadataRows({required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusInfo = _statusPresentation(photo.status, colorScheme);
    final lastModified = _formatTakenAt(photo.original.lastModifiedSync());

    return Column(
      children: [
        _MetaRow(label: 'File', value: path.basename(photo.original.path)),
        _MetaRow(label: 'Last Modified', value: lastModified),
        _MetaRow(
          label: 'Status',
          valueWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusInfo.icon, size: 14, color: statusInfo.color),
              const SizedBox(width: 4.0),
              Text(
                statusInfo.label,
                style: textTheme.bodySmall?.copyWith(color: statusInfo.color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParameterEditors extends StatelessWidget {
  const _ParameterEditors();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ParameterTextField(name: 'folder', label: 'Folder'),
        SizedBox(height: 12.0),
        ParameterTextField(name: 'file', label: 'Filename'),
        SizedBox(height: 12.0),
        ParameterTextField(name: 'number', label: 'Number'),
      ],
    );
  }
}

class _OutputDestinationPreview extends ConsumerWidget {
  const _OutputDestinationPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(context).textTheme.bodySmall;
    final config = ref.watch(configurationProvider);
    final template = config.outputFileNameFormat ?? '';
    final photos = ref.watch(photosProvider);
    final index = ref.watch(photoIndexProvider);
    final hasPhoto = index >= 0 && index < photos.length;
    final photo = hasPhoto ? photos[index] : null;
    final preview = buildOutputTemplateTextSpan(
      template,
      baseStyle: baseStyle,
      placeholderStyles: {
        'folder': (baseStyle ?? const TextStyle()).copyWith(
          color: colorScheme.primary,
        ),
        'filename': (baseStyle ?? const TextStyle()).copyWith(
          color: colorScheme.secondary,
        ),
        'number': (baseStyle ?? const TextStyle()).copyWith(
          color: colorScheme.tertiary,
        ),
        'status': (baseStyle ?? const TextStyle()).copyWith(
          color: colorScheme.error,
        ),
        'original': (baseStyle ?? const TextStyle()).copyWith(
          color: Colors.teal,
        ),
      },
      values: {
        'folder': ref.watch(parameterProvider('folder')),
        'filename': ref.watch(parameterProvider('file')),
        'number': ref.watch(parameterProvider('number')),
        'status': '{status}',
        'original': photo == null ? '' : path.basename(photo.original.path),
      },
      invalidPlaceholderStyle: (baseStyle ?? const TextStyle()).copyWith(
        color: colorScheme.error,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SelectableText.rich(preview, style: baseStyle)],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trailing =
        valueWidget ??
        Text(
          value ?? '',
          style: textTheme.bodySmall,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.labelMedium),
          Flexible(
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}

class _RecentQueueItem extends StatelessWidget {
  const _RecentQueueItem({required this.entry});

  final _QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusInfo = _statusPresentation(entry.status, colorScheme);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(statusInfo.icon, size: 16, color: statusInfo.color),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              path.basename(entry.path),
              style: textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            statusInfo.label,
            style: textTheme.labelSmall?.copyWith(color: statusInfo.color),
          ),
        ],
      ),
    );
  }
}

class AllProcessedMessage extends StatelessWidget {
  const AllProcessedMessage({required this.completionMessage, super.key});

  final String completionMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  completionMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.current,
    required this.total,
    required this.progress,
  });

  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: textTheme.labelMedium),
              Text('$current / $total', style: textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(message, style: textTheme.bodySmall);
  }
}
