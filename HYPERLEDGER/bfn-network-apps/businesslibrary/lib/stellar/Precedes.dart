import 'package:json_annotation/json_annotation.dart';
part 'Precedes.g.dart';
@JsonSerializable()

class Precedes extends Object with _$PrecedesSerializerMixin{
  String href;


  Precedes(this.href);
  factory Precedes.fromJson(Map<String, dynamic> json) => _$PrecedesFromJson(json);

  String getHref() {
    return this.href;
  }

  void setHref(String href) {
    this.href = href;
  }
}
