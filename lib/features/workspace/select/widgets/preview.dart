import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/config.dart';
import '../../../../utils/placement.dart';
import '../../../core/providers/configuration.dart';
import '../../../core/providers/placement_validation.dart';
import '../../../core/providers/watermark.dart';

class ImagePreview extends ConsumerStatefulWidget {
  const ImagePreview({required this.image, super.key});

  final File image;

  @override
  ConsumerState<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends ConsumerState<ImagePreview> {
  late Future<ui.Image> _imageFuture;

  Future<ui.Image> _getImage() async {
    final bytes = await widget.image.readAsBytes();
    return await decodeImageFromList(bytes);
  }

  @override
  void initState() {
    super.initState();
    _imageFuture = _getImage();
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.path != widget.image.path) {
      _imageFuture = _getImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final image = snapshot.data!;
        final imageAspectRatio = image.width / image.height;

        return AspectRatio(
          aspectRatio: imageAspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = width / imageAspectRatio;
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(width, height),
                    painter: ImagePainter(image: image),
                  ),
                  // Overlay watermark only watches watermark/configuration providers
                  Consumer(
                    builder: (context, ref, child) {
                      final watermark = ref.watch(
                        watermarkProvider.select((value) => value.value),
                      );
                      if (watermark == null) {
                        return const SizedBox();
                      }
                      final config = ref.watch(configurationProvider);
                      final placementValidation = ref.watch(
                        placementValidationProvider,
                      );
                      return Stack(
                        children: [
                          CustomPaint(
                            size: Size(width, height),
                            painter: WatermarkPainter(
                              watermark: watermark,
                              config: config,
                              imageWidth: image.width.toDouble(),
                              imageHeight: image.height.toDouble(),
                            ),
                          ),
                          if (placementValidation.status ==
                              PlacementValidationStatus.invalid)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer
                                            .withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          placementValidation.message ??
                                              'Invalid placement',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onErrorContainer,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ImagePainter extends CustomPainter {
  ImagePainter({required this.image});

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final imageSrcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final imageDstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, imageSrcRect, imageDstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! ImagePainter || oldDelegate.image != image;
  }
}

class WatermarkPainter extends CustomPainter {
  WatermarkPainter({
    required this.watermark,
    required this.config,
    required this.imageWidth,
    required this.imageHeight,
  });

  final ui.Image watermark;
  final Config config;
  final double imageWidth;
  final double imageHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final placement = validatePlacement(
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      watermarkSourceWidth: watermark.width.toDouble(),
      watermarkSourceHeight: watermark.height.toDouble(),
      config: config,
    );
    final rect = placement.rect;
    if (rect == null) {
      return;
    }

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final watermarkSrcRect = Rect.fromLTWH(
      0,
      0,
      watermark.width.toDouble(),
      watermark.height.toDouble(),
    );
    final watermarkDstRect = Rect.fromLTWH(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.width * scaleX,
      rect.height * scaleY,
    );
    canvas.drawImageRect(
      watermark,
      watermarkSrcRect,
      watermarkDstRect,
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! WatermarkPainter ||
        oldDelegate.watermark != watermark ||
        oldDelegate.config != config ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight;
  }
}
