import 'package:json_annotation/json_annotation.dart';

part 'Transactions.g.dart';
@JsonSerializable()

class Transactions extends Object with _$TransactionsSerializerMixin{
  String href;

  Transactions(this.href, this.templated);
  factory Transactions.fromJson(Map<String, dynamic> json) => _$TransactionsFromJson(json);


  String getHref() {
    return this.href;
  }

  void setHref(String href) {
    this.href = href;
  }

  bool templated;

  bool getTemplated() {
    return this.templated;
  }

  void setTemplated(bool templated) {
    this.templated = templated;
  }
}
