import 'package:businesslibrary/util/Finders.dart';

class InvoiceBid extends Findable {
  String invoiceBidId;
  String startTime;
  String endTime;
  double reservePercent;
  double amount;
  double discountPercent;
  String offer, wallet;
  String investor, date, autoTradeOrder;
  String user, supplier;
  String invoiceBidAcceptance, customer;
  String supplierName;
  String investorName;
  String customerName;
  bool isSettled;

  InvoiceBid(
      {this.invoiceBidId,
      this.startTime,
      this.endTime,
      this.reservePercent,
      this.amount,
      this.discountPercent,
      this.offer,
      this.investor,
      this.user,
      this.investorName,
      this.date,
      this.autoTradeOrder,
      this.wallet,
      this.isSettled,
      this.supplier,
      this.invoiceBidAcceptance,
      this.supplierName,
      this.customerName,
      this.customer});

  InvoiceBid.fromJson(Map data) {
    this.invoiceBidId = data['invoiceBidId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    try {
      this.reservePercent = data['reservePercent'] * 1.0;
    } catch (e) {
      this.reservePercent = 0.0;
    }
    this.amount = data['amount'] * 1.0;
    try {
      this.discountPercent = data['discountPercent'] * 1.0;
    } catch (e) {
      this.discountPercent = 0.0;
    }
    this.offer = data['offer'];
    this.investor = data['investor'];
    this.user = data['user'];
    if (data['intDate'] == null) {
      this.intDate = DateTime.parse(data['date']).millisecondsSinceEpoch;
    } else {
      this.intDate = data['intDate'];
    }
    this.invoiceBidAcceptance = data['invoiceBidAcceptance'];
    this.user = data['user'];
    this.investorName = data['investorName'];
    this.wallet = data['wallet'];
    this.supplier = data['supplier'];
    this.date = data['date'];
    this.isSettled = data['isSettled'];
    this.autoTradeOrder = data['autoTradeOrder'];
    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];
    this.customer = data['customer'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceBidId': invoiceBidId == null ? ' n/a ' : invoiceBidId,
        'startTime': startTime,
        'endTime': endTime,
        'reservePercent': reservePercent,
        'amount': amount,
        'discountPercent': discountPercent == null ? 0.0 : discountPercent,
        'offer': offer,
        'investor': investor,
        'user': user == null ? ' n/a ' : user,
        'supplierName': supplierName,
        'customerName': customerName,
        'customer': customer,
        'date': date == null ? ' n/a ' : date,
        'intDate': intDate == null ? 0 : intDate,
        'itemNumber': itemNumber == null ? ' n/a ' : itemNumber,
        'invoiceBidAcceptance':
            invoiceBidAcceptance == null ? ' n/a ' : invoiceBidAcceptance,
        'investorName': investorName,
        'wallet': wallet == null ? ' n/a ' : wallet,
        'supplier': supplier,
        'isSettled': isSettled == null ? ' n/a ' : false,
        'autoTradeOrder': autoTradeOrder == null ? ' n/a ' : autoTradeOrder,
      };
}
