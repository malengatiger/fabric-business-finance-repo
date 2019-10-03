// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Flags.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Flags _$FlagsFromJson(Map<String, dynamic> json) =>
    new Flags(json['auth_required'] as bool, json['auth_revocable'] as bool);

abstract class _$FlagsSerializerMixin {
  bool get auth_required;
  bool get auth_revocable;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'auth_required': auth_required,
        'auth_revocable': auth_revocable
      };
}
