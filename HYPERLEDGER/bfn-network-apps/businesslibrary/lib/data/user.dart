class User {
  String userId,
      firstName,
      lastName,
      customer,
      supplier,
      auditor,
      oneConnect,
      procurementOffice,
      investor,
      bank,
      email,
      password,
      cellphone,
      uid;
  String dateRegistered;
  bool isAdministrator;

  User(
      {this.userId,
      this.firstName,
      this.lastName,
      this.customer,
      this.supplier,
      this.auditor,
      this.oneConnect,
      this.procurementOffice,
      this.investor,
      this.bank,
      this.email,
      this.password,
      this.cellphone,
      this.uid,
      this.dateRegistered,
      this.isAdministrator});

  static const companyStaff = "COMPANY",
      govtStaff = 'GOVT_STAFF',
      auditorStaff = 'AUDITOR',
      bankStaff = "BANK",
      supplierStaff = 'SUPPLIER',
      oneConnectStaff = 'ONECONNECT',
      investorStaff = 'INVESTOR',
      procurementStaff = 'PROCUREMENT';

  User.fromJson(Map data) {
    this.userId = data['userId'];
    this.dateRegistered = data['dateRegistered'];
    this.firstName = data['firstName'];
    this.lastName = data['lastName'];
    this.email = data['email'];
    this.password = data['password'];
    this.cellphone = data['cellphone'];
    if (data['isAdministrator'] == 'true') {
      this.isAdministrator = true;
    } else {
      this.isAdministrator = false;
    }
    this.customer = data['customer'];
    this.supplier = data['supplier'];
    this.auditor = data['auditor'];
    this.oneConnect = data['oneConnect'];
    this.procurementOffice = data['procurementOffice'];
    this.investor = data['investor'];
    this.bank = data['bank'];
    this.uid = data['uid'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['userId'] = userId;
    map['dateRegistered'] = dateRegistered;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['email'] = email;
    map['password'] = password;
    if (cellphone != null) {
      map['cellphone'] = cellphone;
    }
    if (cellphone != null) {
      map['cellphone'] = cellphone;
    }
    if (isAdministrator == null) {
      map['isAdministrator'] = false;
    } else {
      map['isAdministrator'] = isAdministrator;
    }
    if (customer != null) {
      map['customer'] = customer;
    }
    if (supplier != null) {
      map['supplier'] = supplier;
    }
    if (investor != null) {
      map['investor'] = investor;
    }
    if (bank != null) {
      map['bank'] = bank;
    }
    if (auditor != null) {
      map['auditor'] = auditor;
    }
    if (procurementOffice != null) {
      map['procurementOffice'] = procurementOffice;
    }
    if (oneConnect != null) {
      map['oneConnect'] = oneConnect;
    }
    if (uid != null) {
      map['uid'] = uid;
    }
    return map;
  }
}
