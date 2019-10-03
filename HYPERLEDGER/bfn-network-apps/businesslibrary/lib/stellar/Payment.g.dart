// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Payment.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => new Payment(
    seed: json['seed'] as String,
    sourceAccount: json['sourceAccount'] as String,
    destinationAccount: json['destinationAccount'] as String,
    amount: json['amount'] as String,
    memo: json['memo'] as String,
    toFCMToken: json['toFCMToken'] as String,
    fromFCMToken: json['fromFCMToken'] as String,
    receiving: json['receiving'] as bool,
    date: json['date'] as int,
    stringDate: json['stringDate'] as String,
    success: json['success'] as bool,
    debug: json['debug'] as bool);

abstract class _$PaymentSerializerMixin {
  String get seed;
  String get sourceAccount;
  String get destinationAccount;
  String get amount;
  String get memo;
  String get stringDate;
  String get toFCMToken;
  String get fromFCMToken;
  bool get receiving;
  bool get success;
  bool get debug;
  int get date;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'seed': seed,
        'sourceAccount': sourceAccount,
        'destinationAccount': destinationAccount,
        'amount': amount,
        'memo': memo,
        'stringDate': stringDate,
        'toFCMToken': toFCMToken,
        'fromFCMToken': fromFCMToken,
        'receiving': receiving,
        'success': success,
        'debug': debug,
        'date': date
      };
}
