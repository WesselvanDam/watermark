import 'dart:io';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../models/photo.dart';
import '../../utils/status.dart';
import '../core/providers/photos.dart';
import '../photo/photoIndex.dart';

const int _recentQueueLimit = 5;

final photoMetadataProvider = FutureProvider.family<_PhotoMetadata, String>((
  ref,
  imagePath,
) async {
  final file = File(imagePath);
  final bytes = await file.readAsBytes();

  int? width;
  int? height;
  DateTime? takenAt;

  ui.decodeImageFromList(bytes, (image) {
    width = image.width;
    height = image.height;
    image.dispose();
  });

  try {
    final exifData = await readExifFromBytes(bytes);
    takenAt = _extractExifDate(exifData);
  } catch (_) {
    takenAt = null;
  }

  return _PhotoMetadata(width: width, height: height, takenAt: takenAt);
});

class _PhotoMetadata {
  const _PhotoMetadata({this.width, this.height, this.takenAt});

  final int? width;
  final int? height;
  final DateTime? takenAt;

  String get dimensionsLabel {
    if (width == null || height == null) {
      return '---';
    }
    return '$width × $height';
  }
}

DateTime? _extractExifDate(Map<String, IfdTag> exifData) {
  const keys = [
    'EXIF DateTimeOriginal',
    'EXIF DateTimeDigitized',
    'Image DateTime',
    'EXIF DateTime',
  ];
  for (final key in keys) {
    final tag = exifData[key];
    if (tag == null) {
      continue;
    }
    final parsed = _parseExifDate(tag.printable);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

DateTime? _parseExifDate(String raw) {
  final match = RegExp(
    r'^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})',
  ).firstMatch(raw.trim());
  if (match == null) {
    return null;
  }

  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
    int.parse(match.group(4)!),
    int.parse(match.group(5)!),
    int.parse(match.group(6)!),
  );
}

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
      label: 'Kept',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PanelHeader(title: 'Inspector', icon: Icons.info_outline),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _Section(
                title: 'Metadata',
                child: photo == null
                    ? const _EmptyState(message: 'No photo selected.')
                    : ref
                          .watch(photoMetadataProvider(photo.original.path))
                          .when(
                            data: (metadata) => _MetadataRows(
                              photo: photo,
                              metadata: metadata,
                              isLoading: false,
                            ),
                            loading: () => _MetadataRows(
                              photo: photo,
                              metadata: null,
                              isLoading: true,
                            ),
                            error: (error, stackTrace) => _MetadataRows(
                              photo: photo,
                              metadata: null,
                              isLoading: false,
                            ),
                          ),
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
              const SizedBox(height: 16.0),
              const _Section(
                title: 'Custom Prefix Variable',
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(hintText: 'e.g. ClientName_'),
                ),
              ),
            ],
          ),
        ),
        _ProgressSection(current: current, total: total, progress: progress),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8.0),
          Text(title, style: textTheme.titleMedium),
        ],
      ),
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
  const _MetadataRows({
    required this.photo,
    required this.metadata,
    required this.isLoading,
  });

  final Photo photo;
  final _PhotoMetadata? metadata;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusInfo = _statusPresentation(photo.status, colorScheme);
    final dimensions =
        metadata?.dimensionsLabel ?? (isLoading ? 'Loading...' : '---');
    final takenAt = metadata == null
        ? (isLoading ? 'Loading...' : '---')
        : _formatTakenAt(metadata?.takenAt);

    return Column(
      children: [
        _MetaRow(label: 'Filename', value: path.basename(photo.original.path)),
        _MetaRow(label: 'Dimensions', value: dimensions),
        _MetaRow(label: 'Date Taken', value: takenAt),
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
          LinearProgressIndicator(value: progress),
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
