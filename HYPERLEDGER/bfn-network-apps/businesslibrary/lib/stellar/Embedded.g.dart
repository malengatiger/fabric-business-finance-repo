// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Embedded.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Embedded _$EmbeddedFromJson(Map<String, dynamic> json) =>
    new Embedded((json['records'] as List)
        ?.map((e) =>
            e == null ? null : new Record.fromJson(e as Map<String, dynamic>))
        ?.toList());

abstract class _$EmbeddedSerializerMixin {
  List<Record> get records;
  Map<String, dynamic> toJson() => <String, dynamic>{'records': records};
}
