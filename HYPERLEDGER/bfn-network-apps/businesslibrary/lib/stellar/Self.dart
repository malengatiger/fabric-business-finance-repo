import 'package:json_annotation/json_annotation.dart';
part 'Self.g.dart';
@JsonSerializable()

class Self extends Object with _$SelfSerializerMixin{
  String href;


  Self(this.href);
  factory Self.fromJson(Map<String, dynamic> json) => _$SelfFromJson(json);


  String getHref() {
    return this.href;
  }

  void setHref(String href) {
    this.href = href;
  }
}
