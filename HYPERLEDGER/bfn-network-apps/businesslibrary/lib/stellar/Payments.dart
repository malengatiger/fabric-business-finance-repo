import 'package:json_annotation/json_annotation.dart';
part 'Payments.g.dart';
@JsonSerializable()

class Payments extends Object with _$PaymentsSerializerMixin{
  String href;

  Payments(this.href, this.templated);
  factory Payments.fromJson(Map<String, dynamic> json) => _$PaymentsFromJson(json);


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
