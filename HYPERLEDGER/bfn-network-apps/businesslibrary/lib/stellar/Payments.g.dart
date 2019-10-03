// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Payments.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Payments _$PaymentsFromJson(Map<String, dynamic> json) =>
    new Payments(json['href'] as String, json['templated'] as bool);

abstract class _$PaymentsSerializerMixin {
  String get href;
  bool get templated;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'href': href, 'templated': templated};
}
