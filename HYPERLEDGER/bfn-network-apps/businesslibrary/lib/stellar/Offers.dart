import 'package:json_annotation/json_annotation.dart';
part 'Offers.g.dart';
@JsonSerializable()

class Offers extends Object with _$OffersSerializerMixin{
  String href;

  Offers(this.href, this.templated);
  factory Offers.fromJson(Map<String, dynamic> json) => _$OffersFromJson(json);


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
