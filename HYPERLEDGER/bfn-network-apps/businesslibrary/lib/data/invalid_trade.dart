import 'dart:convert';

import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/offer.dart';

class InvalidTrade {
  String name, date;
  Offer offer;
  InvestorProfile profile;
  bool validTotal,
      validSector,
      validSupplier,
      validInvoiceAmount,
      validAccountBalance,
      validMinimumDiscount;

  InvalidTrade(
      this.name,
      this.date,
      this.offer,
      this.profile,
      this.validTotal,
      this.validSector,
      this.validSupplier,
      this.validInvoiceAmount,
      this.validAccountBalance,
      this.validMinimumDiscount);

  InvalidTrade.fromJson(Map data) {
    this.name = data['name'];
    this.date = data['date'];
    this.validTotal = data['validTotal'];
    this.validSector = data['validSector'];
    this.validSupplier = data['validSupplier'];
    this.validInvoiceAmount = data['validInvoiceAmount'];
    this.validAccountBalance = data['validAccountBalance'];
    this.validMinimumDiscount = data['validMinimumDiscount'];
    this.offer = Offer.fromJson(json.decode(data['offer']));
    this.profile = InvestorProfile.fromJson(json.decode(data['profile']));
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'date': date,
        'validTotal': validTotal,
        'validSector': validSector,
        'validSupplier': validSupplier,
        'validInvoiceAmount': validInvoiceAmount,
        'validAccountBalance': validAccountBalance,
        'validMinimumDiscount': validMinimumDiscount,
        'offer': offer,
        'profile': profile,
      };
}
