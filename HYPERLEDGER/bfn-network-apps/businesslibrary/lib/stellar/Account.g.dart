// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Account.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => new Account(
    links: json['links'] == null
        ? null
        : new Links.fromJson(json['links'] as Map<String, dynamic>),
    id: json['id'] as String,
    paging_token: json['paging_token'] as String,
    account_id: json['account_id'] as String,
    sequence: json['sequence'] as String,
    subentry_count: json['subentry_count'] as int,
    thresholds: json['thresholds'] == null
        ? null
        : new Thresholds.fromJson(json['thresholds'] as Map<String, dynamic>),
    flags: json['flags'] == null
        ? null
        : new Flags.fromJson(json['flags'] as Map<String, dynamic>),
    signers: (json['signers'] as List)
        ?.map((e) =>
            e == null ? null : new Signer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    data: json['data'] == null
        ? null
        : new Data.fromJson(json['data'] as Map<String, dynamic>),
    balances: (json['balances'] as List)
        ?.map((e) =>
            e == null ? null : new Balance.fromJson(e as Map<String, dynamic>))
        ?.toList());

abstract class _$AccountSerializerMixin {
  Links get links;
  String get id;
  String get paging_token;
  String get account_id;
  String get sequence;
  int get subentry_count;
  Thresholds get thresholds;
  Flags get flags;
  List<Signer> get signers;
  Data get data;
  List<Balance> get balances;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'links': links,
        'id': id,
        'paging_token': paging_token,
        'account_id': account_id,
        'sequence': sequence,
        'subentry_count': subentry_count,
        'thresholds': thresholds,
        'flags': flags,
        'signers': signers,
        'data': data,
        'balances': balances
      };
}
