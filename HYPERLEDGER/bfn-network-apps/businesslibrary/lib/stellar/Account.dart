import 'package:businesslibrary/stellar/Balance.dart';
import 'package:businesslibrary/stellar/Data.dart';
import 'package:businesslibrary/stellar/Flags.dart';
import 'package:businesslibrary/stellar/Links.dart';
import 'package:businesslibrary/stellar/Signer.dart';
import 'package:businesslibrary/stellar/Thresholds.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Account.g.dart';

@JsonSerializable()
class Account extends Object with _$AccountSerializerMixin {
  Links links;
  String id;
  String paging_token;
  String account_id;
  String sequence;
  int subentry_count;
  Thresholds thresholds;
  Flags flags;
  List<Signer> signers;
  Data data;
  List<Balance> balances;

  Account(
      {this.links,
      this.id,
      this.paging_token,
      this.account_id,
      this.sequence,
      this.subentry_count,
      this.thresholds,
      this.flags,
      this.signers,
      this.data,
      this.balances});

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
