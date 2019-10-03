import 'package:json_annotation/json_annotation.dart';
part 'Effects.g.dart';
@JsonSerializable()

class Effects extends Object with _$EffectsSerializerMixin{
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

  Effects(this.href, this.templated);
  factory Effects.fromJson(Map<String, dynamic> json) => _$EffectsFromJson(json);


}
