// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Trades.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Trades _$TradesFromJson(Map<String, dynamic> json) =>
    new Trades(json['href'] as String, json['templated'] as bool);

abstract class _$TradesSerializerMixin {
  String get href;
  bool get templated;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'href': href, 'templated': templated};
}
