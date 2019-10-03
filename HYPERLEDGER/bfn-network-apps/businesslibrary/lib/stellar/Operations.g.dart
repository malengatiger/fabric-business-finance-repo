// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Operations.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Operations _$OperationsFromJson(Map<String, dynamic> json) =>
    new Operations(json['href'] as String, json['templated'] as bool);

abstract class _$OperationsSerializerMixin {
  String get href;
  bool get templated;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'href': href, 'templated': templated};
}
