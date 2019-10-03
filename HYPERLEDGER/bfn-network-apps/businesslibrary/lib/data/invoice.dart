import 'package:businesslibrary/util/Finders.dart';

class Invoice extends Findable {
  String supplier,
      purchaseOrder,
      invoiceId,
      deliveryNote,
      company,
      customer,
      wallet,
      user,
      invoiceNumber,
      description,
      reference,
      supplierContract,
      contractURL,
      invoiceAcceptance,
      deliveryAcceptance,
      settlement,
      supplierName;
  bool isOnOffer, isSettled;
  String date, datePaymentRequired;
  String customerName, purchaseOrderNumber;
  List<String> investorInvoiceSettlements;
  double amount, totalAmount, valueAddedTax;

  Invoice(
      {this.supplier,
      this.invoiceId,
      this.purchaseOrder,
      this.deliveryNote,
      this.company,
      this.customer,
      this.wallet,
      this.user,
      this.settlement,
      this.investorInvoiceSettlements,
      this.isSettled,
      this.invoiceNumber,
      this.description,
      this.reference,
      this.date,
      this.invoiceAcceptance,
      this.deliveryAcceptance,
      this.totalAmount,
      this.valueAddedTax,
      this.purchaseOrderNumber,
      this.customerName,
      this.supplierName,
      this.supplierContract,
      this.datePaymentRequired,
      this.isOnOffer,
      this.contractURL,
      this.amount});

  Invoice.fromJson(Map data) {
    this.totalAmount = data['totalAmount'] * 1.00;
    this.valueAddedTax = data['valueAddedTax'] * 1.00;
    this.amount = data['amount'] * 1.00;

    this.supplier = data['supplier'];
    this.invoiceId = data['invoiceId'];
    this.deliveryNote = data['deliveryNote'];
    this.purchaseOrder = data['purchaseOrder'];
    this.company = data['company'];
    this.customer = data['customer'];
    this.wallet = data['wallet'];
    this.user = data['user'];
    this.invoiceNumber = data['invoiceNumber'];
    this.description = data['description'];
    this.reference = data['reference'];
    this.date = data['date'];
    this.intDate = data['intDate'];
    this.datePaymentRequired = data['datePaymentRequired'];
    this.supplierName = data['supplierName'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];
    this.supplierContract = data['supplierContract'];
    this.isOnOffer = data['isOnOffer'];
    this.settlement = data['settlement'];
    this.isSettled = data['isSettled'];
    this.invoiceAcceptance = data['invoiceAcceptance'];
    this.deliveryAcceptance = data['deliveryAcceptance'];
    this.contractURL = data['contractURL'];
    if (data['itemNumber'] is int) {
      this.itemNumber = data['itemNumber'];
    } else {
      this.itemNumber = 0;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();

    map['totalAmount'] = totalAmount;
    map['valueAddedTax'] = valueAddedTax == null ? ' n/a ' : valueAddedTax;

    map['supplier'] = supplier;
    map['invoiceId'] = invoiceId == null ? ' n/a ' : invoiceId;
    map['deliveryNote'] = deliveryNote == null ? ' n/a ' : deliveryNote;
    map['purchaseOrder'] = purchaseOrder;
    map['customer'] = customer;
    map['wallet'] = wallet == null ? ' n/a ' : wallet;
    map['user'] = user == null ? ' n/a ' : user;
    map['invoiceNumber'] = invoiceNumber;
    map['description'] = description == null ? ' n/a ' : description;
    map['reference'] = reference == null ? ' n/a ' : reference;
    map['date'] = date == null ? ' n/a ' : date;
    map['intDate'] = intDate == null ? 0 : intDate;
    map['datePaymentRequired'] =
        datePaymentRequired == null ? ' n/a ' : datePaymentRequired;
    map['amount'] = amount;
    map['supplierName'] = supplierName;
    map['purchaseOrderNumber'] = purchaseOrderNumber;
    map['customerName'] = customerName;
    map['supplierContract'] =
        supplierContract == null ? ' n/a ' : supplierContract;
    map['isOnOffer'] = isOnOffer == null ? ' n/a ' : false;
    map['settlement'] = settlement == null ? ' n/a ' : settlement;
    map['isSettled'] = isSettled == null ? ' n/a ' : false;
    map['invoiceAcceptance'] =
        invoiceAcceptance == null ? ' n/a ' : invoiceAcceptance;
    map['deliveryAcceptance'] =
        deliveryAcceptance == null ? ' n/a ' : deliveryAcceptance;
    map['contractURL'] = contractURL == null ? ' n/a ' : contractURL;
    map['itemNumber'] = itemNumber == null ? 0 : itemNumber;

    return map;
  }
}
