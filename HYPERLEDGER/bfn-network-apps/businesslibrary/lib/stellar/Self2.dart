import 'package:json_annotation/json_annotation.dart';
part 'Self2.g.dart';
@JsonSerializable()


class Self2 extends Object with _$Self2SerializerMixin{
  String href;


  Self2(this.href);
  factory Self2.fromJson(Map<String, dynamic> json) => _$Self2FromJson(json);


  String getHref() {
    return this.href;
  }

  void setHref(String href) {
    this.href = href;
  }
}
