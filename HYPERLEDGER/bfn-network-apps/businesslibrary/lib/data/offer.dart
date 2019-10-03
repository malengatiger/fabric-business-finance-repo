import 'package:businesslibrary/util/Finders.dart';

class Offer extends Findable {
  String offerId;
  String startTime;
  String endTime, offerCancellation;
  String invoice;
  String purchaseOrder, participantId, wallet;
  String user, date, supplier, contractURL;
  String supplierName, customerName, customer;
  String dateClosed, invoiceAcceptance;
  double invoiceAmount, offerAmount, discountPercent;
  bool isCancelled, isOpen;
  String sector, sectorName;
  Offer(
      {this.offerId,
      this.startTime,
      this.endTime,
      this.discountPercent,
      this.invoice,
      this.date,
      this.invoiceAcceptance,
      this.participantId,
      this.purchaseOrder,
      this.supplier,
      this.dateClosed,
      this.supplierName,
      this.customerName,
      this.invoiceAmount,
      this.offerAmount,
      this.contractURL,
      this.wallet,
      this.isOpen,
      this.customer,
      this.isCancelled,
      this.offerCancellation,
      this.sector,
      this.sectorName,
      this.user});

  Offer.fromJson(Map data) {
    if (data == null) {
      print('Offer.fromJson, ERROR ERROR Map data is NULL - WTF????????????');
      return;
    }
    this.offerId = data['offerId'];
    this.invoiceAcceptance = data['invoiceAcceptance'];
    this.intDate = data['intDate'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.discountPercent = data['discountPercent'] * 1.00;
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.user = data['user'];
    this.date = data['date'];
    this.participantId = data['participantId'];
    this.supplier = data['supplier'];
    this.dateClosed = data['dateClosed'];
    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];
    this.customer = data['customer'];

    this.invoiceAmount = data['invoiceAmount'] * 1.00;
    this.offerAmount = data['offerAmount'] * 1.00;
    this.contractURL = data['contractURL'];
    this.wallet = data['wallet'];
    this.isCancelled = data['isCancelled'];
    this.offerCancellation = data['offerCancellation'];

    this.sector = data['sector'];
    this.sectorName = data['sectorName'];
    this.isOpen = data['isOpen'];
    this.itemNumber = data['itemNumber'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'offerId': offerId == null ? 'n/a' : offerId,
        'invoiceAcceptance':
            invoiceAcceptance == null ? 'n/a' : invoiceAcceptance,
        'intDate': intDate == null ? 0 : intDate,
        'startTime': startTime,
        'endTime': endTime,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user == null ? 'n/a' : user,
        'date': date == null ? 'n/a' : date,
        'participantId': participantId == null ? 'n/a' : participantId,
        'supplier': supplier,
        'dateClosed': dateClosed == null ? 'n/a' : dateClosed,
        'supplierName': supplierName,
        'customerName': customerName,
        'customer': customer,
        'invoiceAmount': invoiceAmount,
        'offerAmount': offerAmount,
        'contractURL': contractURL == null ? 'n/a' : contractURL,
        'wallet': wallet == null ? 'n/a' : wallet,
        'isCancelled': isCancelled == null ? false : isCancelled,
        'offerCancellation':
            offerCancellation == null ? 'n/a' : offerCancellation,
        'sector': sector == null ? 'n/a' : sector,
        'sectorName': sectorName == null ? 'n/a' : sectorName,
        'isOpen': isOpen == null ? true : isOpen,
        'itemNumber': itemNumber == null ? 0 : itemNumber,
      };
}
