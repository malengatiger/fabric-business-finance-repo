import 'package:json_annotation/json_annotation.dart';
part 'Succeeds.g.dart';
@JsonSerializable()

class Succeeds extends Object with _$SucceedsSerializerMixin {
  String href;


  Succeeds(this.href);
  factory Succeeds.fromJson(Map<String, dynamic> json) => _$SucceedsFromJson(json);


  String getHref() {
    return this.href;
  }

  void setHref(String href) {
    this.href = href;
  }
}
