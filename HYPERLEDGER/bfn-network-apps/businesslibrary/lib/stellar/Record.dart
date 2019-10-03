import 'package:json_annotation/json_annotation.dart';

part 'Record.g.dart';

@JsonSerializable()
class Record extends Object with _$RecordSerializerMixin {
  List<dynamic> mLinks;
  String paging_token;
  String id;
  String source_account;
  String type;
  String asset_type;
  String from;
  String to;
  int type_i;
  String account;
  String amount;
  String funder;
  String starting_balance;
  String transaction_hash;
  DateTime created_at;

  Record(
      {this.mLinks,
      this.paging_token,
      this.id,
      this.source_account,
      this.type,
      this.asset_type,
      this.from,
      this.to,
      this.type_i,
      this.account,
      this.amount,
      this.funder,
      this.starting_balance,
      this.transaction_hash,
      this.created_at});

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  Record.fromJSON(Map data) {
    this.paging_token = data['paging_token'];
    this.id = data['id'];
    this.source_account = data['source_account'];
    this.type = data['type'];
    this.asset_type = data['asset_type'];
    this.from = data['from'];
    this.to = data['to'];
    this.type_i = data['type_i'];
    this.account = data['account'];
    this.amount = data['amount'];
    this.funder = data['funder'];
    this.starting_balance = data['starting_balance'];
    this.transaction_hash = data['transaction_hash'];
    this.created_at = data['created_at'];
  }
}

class StellarLink {
  String key, href;

  StellarLink(this.key, this.href);

  StellarLink.fromJson(Map data) {
    this.key = data['key'];
    this.href = data['href'];
  }
  printInfo() {
    print('key $key href: $href');
  }
}
