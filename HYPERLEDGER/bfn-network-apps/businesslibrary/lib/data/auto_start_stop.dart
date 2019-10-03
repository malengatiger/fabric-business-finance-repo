class AutoTradeStart {
  String dateStarted = DateTime.now().toIso8601String();
  String dateEnded = DateTime.now().toIso8601String();
  int totalValidBids = 0, totalOffers = 0, totalInvalidBids = 0;
  double possibleAmount = 0.0, totalAmount = 0.0, elapsedSeconds = 0.0;
  int closedOffers = 0;

  AutoTradeStart(
      {this.dateStarted,
      this.dateEnded,
      this.totalValidBids,
      this.totalOffers,
      this.totalInvalidBids,
      this.possibleAmount,
      this.totalAmount,
      this.elapsedSeconds,
      this.closedOffers});

  AutoTradeStart.fromJson(Map data) {
    this.dateStarted = data['dateStarted'];
    this.dateEnded = data['dateEnded'];
    this.totalValidBids = data['totalValidBids'];
    this.possibleAmount = data['possibleAmount'] * 1.00;
    this.elapsedSeconds = data['elapsedSeconds'];
    this.totalOffers = data['totalOffers'];
    this.totalInvalidBids = data['totalInvalidBids'];
    this.totalAmount = data['totalAmount'] * 1.0;
    this.closedOffers = data['closedOffers'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dateStarted': dateStarted,
        'dateEnded': dateEnded,
        'totalValidBids': totalValidBids,
        'possibleAmount': possibleAmount,
        'elapsedSeconds': elapsedSeconds,
        'totalOffers': totalOffers,
        'totalInvalidBids': totalInvalidBids,
        'totalAmount': totalAmount,
        'closedOffers': closedOffers,
      };
}
