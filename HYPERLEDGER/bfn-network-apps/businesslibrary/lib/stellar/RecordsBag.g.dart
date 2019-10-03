// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RecordsBag.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

RecordsBag _$RecordsBagFromJson(Map<String, dynamic> json) =>
    new RecordsBag((json['payments'] as List)
        ?.map((e) =>
            e == null ? null : new Record.fromJson(e as Map<String, dynamic>))
        ?.toList());

abstract class _$RecordsBagSerializerMixin {
  List<Record> get payments;
  Map<String, dynamic> toJson() => <String, dynamic>{'payments': payments};
}
