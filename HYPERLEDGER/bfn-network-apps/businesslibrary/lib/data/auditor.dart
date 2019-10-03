import 'package:json_annotation/json_annotation.dart';

//part 'auditor.g.dart';
/*
extends Object with _$AuditorSerializerMixin
 */
@JsonSerializable(nullable: false)
class Auditor {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address, country, dateRegistered;

  Auditor({
    this.participantId,
    this.name,
    this.cellphone,
    this.email,
    this.description,
    this.address,
    this.dateRegistered,
    this.country,
  });

//  factory Auditor.fromJson(Map<String, dynamic> json) =>
//      _$AuditorFromJson(data);

  Auditor.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['address'];
    this.country = data['country'];
    this.dateRegistered = data['dateRegistered'];
  }
  Map<String, String> toJson() => <String, String>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'dateRegistered': dateRegistered,
      };
}
