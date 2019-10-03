import 'package:businesslibrary/util/Finders.dart';

class DeliveryAcceptance extends Findable {
  String acceptanceId;
  String date;
  String deliveryNote;
  String customer, purchaseOrder, purchaseOrderNumber, customerName;
  String user, supplier;

  DeliveryAcceptance(
      {this.acceptanceId,
      this.date,
      this.deliveryNote,
      this.customer,
      this.user,
      this.supplier,
      this.customerName,
      this.purchaseOrderNumber,
      this.purchaseOrder});

  DeliveryAcceptance.fromJson(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.date = data['date'];
    this.deliveryNote = data['deliveryNote'];
    this.customer = data['customer'];
    this.user = data['user'];
    this.supplier = data['supplier'];
    this.purchaseOrder = data['purchaseOrder'];

    this.customerName = data['customerName'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
  }
  Map<String, String> toJson() => <String, String>{
        'acceptanceId': acceptanceId == null ? ' n/a ' : acceptanceId,
        'date': date == null ? ' n/a ' : date,
        'deliveryNote': deliveryNote,
        'customer': customer,
        'purchaseOrder': purchaseOrder == null ? ' n/a ' : purchaseOrder,
        'user': user == null ? ' n/a ' : user,
        'supplier': supplier,
        'customerName': customerName,
        'purchaseOrderNumber':
            purchaseOrderNumber == null ? ' n/a ' : purchaseOrderNumber,
      };
}
