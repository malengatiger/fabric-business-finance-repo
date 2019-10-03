import 'package:businesslibrary/data/misc_data.dart';

class Customer extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address, dateRegistered;
  String country;
  bool allowAutoAccept;

  Customer(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.country,
      this.allowAutoAccept,
      this.dateRegistered});

  static const National = "NATIONAL",
      Municipality = 'MUNICIPALITY',
      Provincial = 'PROVINCIAL';

  Customer.fromJson(Map data) {
    print(data);
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['email'];
    this.country = data['country'];
    this.dateRegistered = data['dateRegistered'];
    this.allowAutoAccept = data['allowAutoAccept'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'dateRegistered': dateRegistered,
        'allowAutoAccept': allowAutoAccept,
      };
}
