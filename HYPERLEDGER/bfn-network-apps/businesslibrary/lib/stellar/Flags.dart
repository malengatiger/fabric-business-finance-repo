import 'package:json_annotation/json_annotation.dart';
part 'Flags.g.dart';
@JsonSerializable()

class Flags extends Object with _$FlagsSerializerMixin{

  bool auth_required;

  bool getAuthRequired() {
    return this.auth_required;
  }

  void setAuthRequired(bool auth_required) {
    this.auth_required = auth_required;
  }

  bool auth_revocable;

  bool getAuthRevocable() {
    return this.auth_revocable;
  }

  void setAuthRevocable(bool auth_revocable) {
    this.auth_revocable = auth_revocable;
  }

  Flags(this.auth_required, this.auth_revocable);
  factory Flags.fromJson(Map<String, dynamic> json) => _$FlagsFromJson(json);

}
