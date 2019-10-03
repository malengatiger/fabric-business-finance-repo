import 'package:businesslibrary/util/Finders.dart';

class DeliveryNote extends Findable {
  String deliveryNoteId,
      purchaseOrder,
      customer,
      user,
      acceptedBy,
      deliveryNoteURL,
      supplier,
      supplierName,
      remarks;
  double amount, vat, totalAmount;
  String date, dateAccepted;
  String purchaseOrderNumber, customerName;

  DeliveryNote(
      {this.deliveryNoteId,
      this.purchaseOrder,
      this.customer,
      this.user,
      this.acceptedBy,
      this.deliveryNoteURL,
      this.supplier,
      this.supplierName,
      this.remarks,
      this.date,
      this.amount,
      this.vat,
      this.totalAmount,
      this.dateAccepted,
      this.purchaseOrderNumber,
      this.customerName});

  DeliveryNote.fromJson(Map data) {
    this.deliveryNoteId = data['deliveryNoteId'];
    this.purchaseOrder = data['purchaseOrder'];
    this.customer = data['customer'];
    this.user = data['user'];
    this.deliveryNoteURL = data['deliveryNoteURL'];
    this.remarks = data['remarks'];

    this.date = data['date'];
    if (data['intDate'] is int) {
      this.intDate = data['intDate'];
    } else {
      this.intDate = 0;
    }

    this.dateAccepted = data['dateAccepted'];
    this.acceptedBy = data['acceptedBy'];
    this.supplierName = data['supplierName'];
    this.supplier = data['supplier'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];

    if (data['amount'] is int) {
      this.amount = data['amount'] * 1.0;
    } else {
      this.amount = data['amount'];
    }
    if (data['vat'] is int) {
      this.vat = data['vat'] * 1.0;
    } else {
      this.vat = data['vat'];
    }
    if (data['totalAmount'] is int) {
      this.totalAmount = data['totalAmount'] * 1.0;
    } else {
      this.totalAmount = data['totalAmount'];
    }
  }

  Map<String, dynamic> toJson() {
    var map = {
      'deliveryNoteId': deliveryNoteId == null ? 'n/a' : deliveryNoteId,
      'purchaseOrder': purchaseOrder,
      'customer': customer,
      'user': user == null ? 'n/a' : user,
      'deliveryNoteURL': deliveryNoteURL == null ? 'n/a' : deliveryNoteURL,
      'remarks': remarks == null ? 'n/a' : remarks,
      'date': date == null ? 'n/a' : date,
      'intDate': intDate == null ? 0 : intDate,
      'dateAccepted': dateAccepted == null ? 'n/a' : dateAccepted,
      'acceptedBy': acceptedBy == null ? 'n/a' : acceptedBy,
      'supplierName': supplierName,
      'supplier': supplier,
      'purchaseOrderNumber': purchaseOrderNumber,
      'customerName': customerName,
      'amount': amount,
      'vat': vat == null ? 'n/a' : 0.0,
      'totalAmount': totalAmount,
    };
    return map;
  }
}
