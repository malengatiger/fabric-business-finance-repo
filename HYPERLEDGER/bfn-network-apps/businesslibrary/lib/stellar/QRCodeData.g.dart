// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QRCodeData.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

QRCodeData _$QRCodeDataFromJson(Map<String, dynamic> json) => new QRCodeData(
    accountID: json['accountID'] as String,
    walletID: json['walletID'] as String,
    url: json['url'] as String,
    name: json['name'] as String);

abstract class _$QRCodeDataSerializerMixin {
  String get accountID;
  String get walletID;
  String get url;
  String get name;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'accountID': accountID,
        'walletID': walletID,
        'url': url,
        'name': name
      };
}
