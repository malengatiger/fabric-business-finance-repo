// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Links2.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Links2 _$Links2FromJson(Map<String, dynamic> json) => new Links2(
    json['self'] == null
        ? null
        : new Self2.fromJson(json['self'] as Map<String, dynamic>),
    json['effects'] == null
        ? null
        : new Effects.fromJson(json['effects'] as Map<String, dynamic>),
    json['succeeds'] == null
        ? null
        : new Succeeds.fromJson(json['succeeds'] as Map<String, dynamic>),
    json['precedes'] == null
        ? null
        : new Precedes.fromJson(json['precedes'] as Map<String, dynamic>));

abstract class _$Links2SerializerMixin {
  Self2 get self;
  Effects get effects;
  Succeeds get succeeds;
  Precedes get precedes;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'self': self,
        'effects': effects,
        'succeeds': succeeds,
        'precedes': precedes
      };
}
