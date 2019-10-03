import 'package:json_annotation/json_annotation.dart';
part 'QRCodeData.g.dart';
@JsonSerializable()

class QRCodeData extends Object with _$QRCodeDataSerializerMixin{
  String accountID, walletID, url, name;

  QRCodeData({this.accountID, this.walletID, this.url, this.name});
  factory QRCodeData.fromJson(Map<String, dynamic> json) => _$QRCodeDataFromJson(json);


}