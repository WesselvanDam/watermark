import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/config.dart';
import '../../../../providers/configuration.dart';
import '../../../../providers/watermark.dart';

class ImagePreview extends ConsumerStatefulWidget {
  const ImagePreview({required this.image, super.key});

  final File image;

  @override
  ConsumerState<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends ConsumerState<ImagePreview> {
  Future<ui.Image> _getImage() async {
    return decodeImageFromList(widget.image.readAsBytesSync());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _getImage(),
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
                    painter: ImagePainter(
                      image: image,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final watermark = ref.watch(
                        watermarkProvider.select((value) => value.value),
                      );
                      if (watermark == null) {
                        return const SizedBox();
                      }
                      final config = ref.watch(configurationProvider);
                      return CustomPaint(
                        size: Size(width, height),
                        painter: WatermarkPainter(
                          watermark: watermark,
                          config: config,
                          imageWidth: image.width.toDouble(),
                          imageHeight: image.height.toDouble(),
                        ),
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
  ImagePainter({
    required this.image,
  });

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
    return false;
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
    final watermarkWidth = watermark.width.toDouble();
    final watermarkHeight = watermark.height.toDouble();

    final watermarkSrcRect =
        Rect.fromLTWH(0, 0, watermarkWidth, watermarkHeight);

    final width =
        imageWidth * config.watermarkWidthFraction * size.width / imageWidth;
    final height = width * (watermarkHeight / watermarkWidth);
    final watermarkDstRect = Rect.fromLTWH(
      (imageWidth * config.watermarkLeftFraction) * size.width / imageWidth -
          width,
      (imageHeight * config.watermarkTopFraction) * size.height / imageHeight -
          height,
      width,
      height,
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
    return false;
  }
}
