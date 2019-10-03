// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Links.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Links _$LinksFromJson(Map<String, dynamic> json) => new Links(
    json['self'] == null
        ? null
        : new Self.fromJson(json['self'] as Map<String, dynamic>),
    json['transactions'] == null
        ? null
        : new Transactions.fromJson(
            json['transactions'] as Map<String, dynamic>),
    json['operations'] == null
        ? null
        : new Operations.fromJson(json['operations'] as Map<String, dynamic>),
    json['payments'] == null
        ? null
        : new Payments.fromJson(json['payments'] as Map<String, dynamic>),
    json['effects'] == null
        ? null
        : new Effects.fromJson(json['effects'] as Map<String, dynamic>),
    json['offers'] == null
        ? null
        : new Offers.fromJson(json['offers'] as Map<String, dynamic>),
    json['trades'] == null
        ? null
        : new Trades.fromJson(json['trades'] as Map<String, dynamic>),
    json['data'] == null
        ? null
        : new Data.fromJson(json['data'] as Map<String, dynamic>));

abstract class _$LinksSerializerMixin {
  Self get self;
  Transactions get transactions;
  Operations get operations;
  Payments get payments;
  Effects get effects;
  Offers get offers;
  Trades get trades;
  Data get data;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'self': self,
        'transactions': transactions,
        'operations': operations,
        'payments': payments,
        'effects': effects,
        'offers': offers,
        'trades': trades,
        'data': data
      };
}
