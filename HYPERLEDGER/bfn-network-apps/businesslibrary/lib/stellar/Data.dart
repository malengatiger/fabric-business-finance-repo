import 'package:json_annotation/json_annotation.dart';

part 'Data.g.dart';
@JsonSerializable()

class Data extends Object with _$DataSerializerMixin{

  String href;


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

  Data(this.href, this.templated);
  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

}
