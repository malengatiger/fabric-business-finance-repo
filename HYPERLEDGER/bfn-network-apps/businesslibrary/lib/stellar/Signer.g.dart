// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Signer.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Signer _$SignerFromJson(Map<String, dynamic> json) => new Signer(
    json['public_key'] as String,
    json['weight'] as int,
    json['key'] as String,
    json['type'] as String);

abstract class _$SignerSerializerMixin {
  String get public_key;
  int get weight;
  String get key;
  String get type;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'public_key': public_key,
        'weight': weight,
        'key': key,
        'type': type
      };
}
