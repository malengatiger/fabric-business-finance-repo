class InvoiceBidAcceptance {
  String acceptanceId;
  String date;
  String invoiceBid;
  String user;

  InvoiceBidAcceptance(
      {this.acceptanceId, this.date, this.invoiceBid, this.user});

  InvoiceBidAcceptance.fromJson(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.date = data['date'];
    this.invoiceBid = data['invoiceBid'];
    this.user = data['user'];
  }
  Map<String, String> toJson() => <String, String>{
        'acceptanceId': acceptanceId,
        'date': date,
        'invoiceBid': invoiceBid,
        'user': user
      };
}
