// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Data.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) =>
    new Data(json['href'] as String, json['templated'] as bool);

abstract class _$DataSerializerMixin {
  String get href;
  bool get templated;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'href': href, 'templated': templated};
}
