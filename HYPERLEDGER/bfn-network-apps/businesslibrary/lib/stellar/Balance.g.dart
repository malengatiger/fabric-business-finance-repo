// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Balance.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Balance _$BalanceFromJson(Map<String, dynamic> json) =>
    new Balance(json['balance'] as String, json['asset_type'] as String);

abstract class _$BalanceSerializerMixin {
  String get balance;
  String get asset_type;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'balance': balance, 'asset_type': asset_type};
}
