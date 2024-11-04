import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
class Config with _$Config {
  const factory Config({
    @Default(null) String? inputPath,
    @Default(null) String? watermarkPath,
    @Default(null) String? outputPath,
    @Default(null) String? outputFileNameFormat,
    @Default(0.99) double watermarkLeftFraction,
    @Default(0.99) double watermarkTopFraction,
    @Default(0.2) double watermarkWidthFraction,
  }) = _Config;

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
}

typedef ConfigTransformCallback<T> = T Function(Config config);
