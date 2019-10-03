// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Record.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) => new Record(
    mLinks: json['mLinks'] as List,
    paging_token: json['paging_token'] as String,
    id: json['id'] as String,
    source_account: json['source_account'] as String,
    type: json['type'] as String,
    asset_type: json['asset_type'] as String,
    from: json['from'] as String,
    to: json['to'] as String,
    type_i: json['type_i'] as int,
    account: json['account'] as String,
    amount: json['amount'] as String,
    funder: json['funder'] as String,
    starting_balance: json['starting_balance'] as String,
    transaction_hash: json['transaction_hash'] as String,
    created_at: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String));

abstract class _$RecordSerializerMixin {
  List<dynamic> get mLinks;
  String get paging_token;
  String get id;
  String get source_account;
  String get type;
  String get asset_type;
  String get from;
  String get to;
  int get type_i;
  String get account;
  String get amount;
  String get funder;
  String get starting_balance;
  String get transaction_hash;
  DateTime get created_at;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'mLinks': mLinks,
        'paging_token': paging_token,
        'id': id,
        'source_account': source_account,
        'type': type,
        'asset_type': asset_type,
        'from': from,
        'to': to,
        'type_i': type_i,
        'account': account,
        'amount': amount,
        'funder': funder,
        'starting_balance': starting_balance,
        'transaction_hash': transaction_hash,
        'created_at': created_at?.toIso8601String()
      };
}
