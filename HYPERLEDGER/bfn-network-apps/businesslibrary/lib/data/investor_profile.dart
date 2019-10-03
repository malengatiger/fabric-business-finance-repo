class InvestorProfile {
  String profileId;
  String name;
  String cellphone;
  String email, date;
  double maxInvestableAmount, maxInvoiceAmount;
  double minimumDiscount;
  String investor;
  List<String> sectors, suppliers;

  InvestorProfile(
      {this.profileId,
      this.name,
      this.cellphone,
      this.email,
      this.date,
      this.sectors,
      this.suppliers,
      this.minimumDiscount,
      this.maxInvestableAmount,
      this.maxInvoiceAmount,
      this.investor});

  InvestorProfile.fromJson(Map data) {
    this.profileId = data['profileId'];
    this.name = data['name'];
    this.maxInvestableAmount = data['maxInvestableAmount'] * 1.00;
    this.maxInvoiceAmount = data['maxInvoiceAmount'] * 1.00;
    this.cellphone = data['cellphone'];
    this.investor = data['investor'];
    this.email = data['email'];
    this.investor = data['investor'];
    this.minimumDiscount = data['minimumDiscount'] * 1.0;

    this.date = data['date'];
    List list = data['sectors'];

    this.sectors = List();
    if (list != null) {
      list.forEach((s) {
        this.sectors.add(s);
      });
    }
    List list2 = data['suppliers'];
    this.suppliers = List();
    if (list2 != null) {
      list2.forEach((s) {
        this.suppliers.add(s);
      });
    }
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'profileId': profileId == null ? 'n/a' : profileId,
        'name': name,
        'date': date == null ? 'n/a' : date,
        'maxInvestableAmount':
            maxInvestableAmount == null ? 0.0 : maxInvestableAmount,
        'cellphone': cellphone == null ? 'n/a' : cellphone,
        'maxInvoiceAmount': maxInvoiceAmount == null ? 0.0 : maxInvoiceAmount,
        'email': email == null ? 'n/a' : email,
        'investor': investor,
        'sectors': sectors == null ? List() : sectors,
        'suppliers': suppliers == null ? List() : suppliers,
        'minimumDiscount': minimumDiscount == null ? 0.0 : minimumDiscount,
      };
}
