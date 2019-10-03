// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PaymentFailed.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

PaymentFailed _$PaymentFailedFromJson(Map<String, dynamic> json) =>
    new PaymentFailed(
        json['fcmToken'] as String,
        json['destinationAccount'] as String,
        json['sourceAccount'] as String,
        json['amount'] as String,
        json['memo'] as String,
        json['error'] as String,
        json['stringDate'] as String,
        json['date'] as int);

abstract class _$PaymentFailedSerializerMixin {
  String get fcmToken;
  String get destinationAccount;
  String get sourceAccount;
  String get amount;
  String get memo;
  String get error;
  String get stringDate;
  int get date;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'fcmToken': fcmToken,
        'destinationAccount': destinationAccount,
        'sourceAccount': sourceAccount,
        'amount': amount,
        'memo': memo,
        'error': error,
        'stringDate': stringDate,
        'date': date
      };
}
