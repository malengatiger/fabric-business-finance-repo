// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PaymentsResponse.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

PaymentsResponse _$PaymentsResponseFromJson(Map<String, dynamic> json) =>
    new PaymentsResponse(
        json['links'] == null
            ? null
            : new Links.fromJson(json['links'] as Map<String, dynamic>),
        json['embedded'] == null
            ? null
            : new Embedded.fromJson(json['embedded'] as Map<String, dynamic>));

abstract class _$PaymentsResponseSerializerMixin {
  Links get links;
  Embedded get embedded;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'links': links, 'embedded': embedded};
}
