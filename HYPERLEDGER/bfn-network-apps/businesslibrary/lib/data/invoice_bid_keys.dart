class InvoiceBidKeys {
  String investorDocRef, investorName;
  String date;
  List<String> keys = List();

  InvoiceBidKeys({this.investorDocRef, this.investorName, this.date, this.keys});

  addKey(String key) {
    keys.add(key);
  }

  InvoiceBidKeys.fromJson(Map data) {
    this.investorName = data['investorName'];
    this.date = data['date'];
    this.keys = data['keys'];
    this.investorDocRef = data['investorDocRef'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
    'investorName': investorName,
    'date': date,
    'keys': keys,
    'investorDocRef': investorDocRef,

  };
}