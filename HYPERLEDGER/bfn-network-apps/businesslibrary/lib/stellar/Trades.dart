import 'package:json_annotation/json_annotation.dart';

part 'Trades.g.dart';
@JsonSerializable()

class Trades extends Object with _$TradesSerializerMixin{
  String href;

  Trades(this.href, this.templated);
  factory Trades.fromJson(Map<String, dynamic> json) => _$TradesFromJson(json);


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
