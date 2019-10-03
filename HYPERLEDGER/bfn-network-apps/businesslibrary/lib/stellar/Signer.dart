import 'package:json_annotation/json_annotation.dart';
part 'Signer.g.dart';
@JsonSerializable()

class Signer extends Object with _$SignerSerializerMixin{
  String public_key;


  Signer(this.public_key, this.weight, this.key, this.type);
  factory Signer.fromJson(Map<String, dynamic> json) => _$SignerFromJson(json);


  String getPublicKey() {
    return this.public_key;
  }

  void setPublicKey(String public_key) {
    this.public_key = public_key;
  }

  int weight;

  int getWeight() {
    return this.weight;
  }

  void setWeight(int weight) {
    this.weight = weight;
  }

  String key;

  String getKey() {
    return this.key;
  }

  void setKey(String key) {
    this.key = key;
  }

  String type;

  String getType() {
    return this.type;
  }

  void setType(String type) {
    this.type = type;
  }
}
