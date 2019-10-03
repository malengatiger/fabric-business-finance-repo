import 'package:businesslibrary/stellar/sdk/offer_response.dart';

class OrderBookResponse {
  Asset base;
  Asset counter;
  List<Row> asks;
  List<Row> bids;

  OrderBookResponse(this.base, this.counter, this.asks, this.bids);
}

class Row {
  String amount;
  String price;
  Price priceR;

  Row(this.amount, this.price, this.priceR);
}

class Price {
  int n, d;

  Price(this.n, this.d);
}
