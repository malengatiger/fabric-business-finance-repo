class Wallet {
  String stellarPublicKey;
  String dateRegistered;
  String name;
  String govtEntity;
  String company;
  String supplier;
  String procurementOffice;
  String oneConnect;
  String auditor, sourceSeed;
  String bank, secret, fcmToken, encryptedSecret;
  String investor;
  bool debug;

  Wallet(
      {this.stellarPublicKey,
      this.dateRegistered,
      this.name,
      this.govtEntity,
      this.company,
      this.supplier,
      this.procurementOffice,
      this.oneConnect,
      this.auditor,
      this.bank,
      this.debug,
      this.secret,
      this.sourceSeed,
      this.fcmToken,
      this.encryptedSecret,
      this.investor});

  Wallet.fromJson(Map data) {
    this.stellarPublicKey = data['stellarPublicKey'];
    this.dateRegistered = data['dateRegistered'];
    this.name = data['name'];
    this.govtEntity = data['govtEntity'];
    this.company = data['company'];
    this.supplier = data['supplier'];
    this.oneConnect = data['oneConnect'];
    this.auditor = data['auditor'];
    this.bank = data['bank'];
    this.investor = data['investor'];
    this.secret = data['secret'];
    this.fcmToken = data['fcmToken'];
    this.sourceSeed = data['sourceSeed'];
    this.debug = data['debug'];
    this.encryptedSecret = data['encryptedSecret'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'stellarPublicKey': stellarPublicKey,
        'dateRegistered': dateRegistered,
        'name': name,
        'govtEntity': govtEntity,
        'company': company,
        'supplier': supplier,
        'procurementOffice': procurementOffice,
        'oneConnect': oneConnect,
        'auditor': auditor,
        'bank': bank,
        'investor': investor,
        'secret': secret,
        'fcmToken': fcmToken,
        'sourceSeed': sourceSeed,
        'debug': debug,
        'encryptedSecret': encryptedSecret,
      };
}
