import 'package:json_annotation/json_annotation.dart';
part 'Operations.g.dart';
@JsonSerializable()

class Operations extends Object with _$OperationsSerializerMixin{
  String href;

  Operations(this.href, this.templated);
  factory Operations.fromJson(Map<String, dynamic> json) => _$OperationsFromJson(json);


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
