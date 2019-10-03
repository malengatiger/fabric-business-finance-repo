// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Transactions.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Transactions _$TransactionsFromJson(Map<String, dynamic> json) =>
    new Transactions(json['href'] as String, json['templated'] as bool);

abstract class _$TransactionsSerializerMixin {
  String get href;
  bool get templated;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'href': href, 'templated': templated};
}
