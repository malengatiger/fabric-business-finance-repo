import 'package:businesslibrary/util/lookups.dart';

class InvestorBidSummary {
  int totalUnsettledBids = 0, totalSettledBids = 0;
  double totalUnsettledBidAmount = 0.0, totalSettledBidAmount = 0.0;

  InvestorBidSummary(
      {this.totalUnsettledBids,
      this.totalUnsettledBidAmount,
      this.totalSettledBidAmount,
      this.totalSettledBids});

  InvestorBidSummary.fromJson(Map data) {
    prettyPrint(data, '################### Investor Summary');
    this.totalUnsettledBids = data['totalUnsettledBids'];
    this.totalUnsettledBidAmount = data['totalUnsettledBidAmount'] * 1.0;
    this.totalSettledBidAmount = data['totalSettledBidAmount'] * 1.0;
    this.totalSettledBids = data['totalSettledBids'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalUnsettledBids': totalUnsettledBids,
        'totalUnsettledBidAmount': totalUnsettledBidAmount,
        'totalSettledBidAmount': totalSettledBidAmount,
        'totalSettledBids': totalSettledBids,
      };
}
