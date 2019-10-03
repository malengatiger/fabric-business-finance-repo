import 'package:businesslibrary/data/misc_data.dart';

class Company extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address, dateRegistered;
  String sector, country;
  bool allowAutoAccept;

  Company(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.country,
      this.allowAutoAccept,
      this.dateRegistered,
      this.sector});

  Company.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.sector = data['sector'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['address'];
    this.country = data['country'];
    this.dateRegistered = data['dateRegistered'];
    this.allowAutoAccept = data['allowAutoAccept'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'privateSectorType': sector,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'sector': sector,
        'allowAutoAccept': allowAutoAccept,
        'dateRegistered': dateRegistered,
      };
}
