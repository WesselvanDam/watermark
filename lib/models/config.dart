import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
abstract class Config with _$Config {
  const factory Config({
    @Default(null) String? inputPath,
    @Default(true) bool includeSubdirectories,
    @Default(null) String? watermarkPath,
    @Default(null) String? outputPath,
    @Default(null) String? outputFileNameFormat,
    @Default(null) int? originalMaxSize,
    @Default(null) int? watermarkedMaxSize,
    @Default(0.98) double watermarkLeftFraction,
    @Default(0.98) double watermarkTopFraction,
    @Default(0.2) double watermarkWidthFraction,
    @Default(1.0) double watermarkAnchorX,
    @Default(1.0) double watermarkAnchorY,
  }) = _Config;

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
}

typedef ConfigTransformCallback<T> = T Function(Config config);
