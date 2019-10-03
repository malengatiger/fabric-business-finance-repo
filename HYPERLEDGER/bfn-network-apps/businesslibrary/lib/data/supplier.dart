import 'package:businesslibrary/data/misc_data.dart';

class Supplier extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address, dateRegistered;
  String sector, country, sectorName;
  bool isSelected;

  Supplier(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.country,
      this.dateRegistered,
      this.sector,
      this.sectorName,
      this.isSelected});

  static const Technology = "TECHNOLOGY",
      Retail = "RETAIL",
      Industrial = 'INDUSTRIAL',
      Agricultural = 'AGRICULTURAL',
      Informal = 'INFORMAL_TRADE',
      Construction = 'CONSTRUCTION',
      FinancialServices = 'FINANCIAL_SERVICES',
      Education = 'EDUCATIONAL';

  Supplier.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.sector = data['sector'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['address'];
    this.country = data['country'];
    this.dateRegistered = data['dateRegistered'];
    this.sectorName = data['sectorName'];
  }
  Map<String, String> toJson() => <String, String>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'sector': sector,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'dateRegistered': dateRegistered,
        'sectorName': sectorName,
      };
}
