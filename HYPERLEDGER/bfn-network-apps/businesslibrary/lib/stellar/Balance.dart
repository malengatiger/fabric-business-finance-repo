import 'package:json_annotation/json_annotation.dart';

part 'Balance.g.dart';

@JsonSerializable()
class Balance extends Object with _$BalanceSerializerMixin {
  String balance;
  String asset_type;

  Balance(this.balance, this.asset_type);
  factory Balance.fromJson(Map<String, dynamic> json) =>
      _$BalanceFromJson(json);

  String getBalance() {
    return this.balance;
  }

  void setBalance(String balance) {
    this.balance = balance;
  }

  String getAssetType() {
    return this.asset_type;
  }

  void setAssetType(String asset_type) {
    this.asset_type = asset_type;
  }
}
