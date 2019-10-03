// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Thresholds.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Thresholds _$ThresholdsFromJson(Map<String, dynamic> json) => new Thresholds(
    json['low_threshold'] as int,
    json['med_threshold'] as int,
    json['high_threshold'] as int);

abstract class _$ThresholdsSerializerMixin {
  int get low_threshold;
  int get med_threshold;
  int get high_threshold;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'low_threshold': low_threshold,
        'med_threshold': med_threshold,
        'high_threshold': high_threshold
      };
}
