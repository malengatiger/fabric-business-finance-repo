class AutoTradeOrder {
  String autoTradeOrderId;
  String date;
  String investorName;
  String dateCancelled, wallet;
  String investorProfile, user, investor;
  bool isCancelled;
  AutoTradeOrder(
      {this.autoTradeOrderId,
      this.date,
      this.investor,
      this.investorName,
      this.dateCancelled,
      this.isCancelled,
      this.wallet,
      this.investorProfile,
      this.user});

  AutoTradeOrder.fromJson(Map data) {
    this.autoTradeOrderId = data['autoTradeOrderId'];
    this.date = data['date'];
    this.investorName = data['investorName'];
    this.dateCancelled = data['dateCancelled'];
    this.investorProfile = data['investorProfile'];
    this.user = data['user'];
    this.investor = data['investor'];
    this.isCancelled = data['isCancelled'];
    this.wallet = data['wallet'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'autoTradeOrderId': autoTradeOrderId,
        'date': date,
        'investorName': investorName,
        'dateCancelled': dateCancelled,
        'investorProfile': investorProfile,
        'user': user,
        'investor': investor,
        'isCancelled': isCancelled,
        'wallet': wallet,
      };
}
