import 'package:businesslibrary/data/item.dart';
import 'package:businesslibrary/util/Finders.dart';

class PurchaseOrder extends Findable {
  String supplier, company, govtEntity, user;
  String purchaseOrderId;
  String date, deliveryDateRequired;
  double amount;

  String description;
  String deliveryAddress;
  String supplierName, customer;

  String purchaseOrderNumber, purchaserName;
  String purchaseOrderURL, contractURL;
  List<PurchaseOrderItem> items;

  PurchaseOrder(
      {this.supplier,
      this.customer,
      this.user,
      this.purchaseOrderId,
      this.date,
      this.deliveryDateRequired,
      this.amount,
      this.description,
      this.deliveryAddress,
      this.purchaseOrderNumber,
      this.supplierName,
      this.purchaserName,
      this.items,
      this.contractURL,
      this.purchaseOrderURL});

  PurchaseOrder.fromJson(Map data) {
    this.supplier = data['supplier'];
    this.customer = data['customer'];
    this.purchaseOrderId = data['purchaseOrderId'];
    this.user = data['user'];
    this.date = data['date'];
    this.intDate = data['intDate'];
    this.deliveryDateRequired = data['deliveryDateRequired'];
    this.amount = data['amount'] * 1.0;
    this.description = data['description'];
    this.deliveryAddress = data['deliveryAddress'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.purchaseOrderURL = data['purchaseOrderURL'];
    this.supplierName = data['supplierName'];
    this.purchaserName = data['purchaserName'];
    this.contractURL = data['contractURL'];
    this.itemNumber = data['itemNumber'];
    this.items = List();
  }
  Map<String, dynamic> toJson() {
    var map = {
      'supplier': supplier,
      'purchaseOrderId': purchaseOrderId == null ? 'n/a' : purchaseOrderId,
      'customer': customer,
      'user': user == null ? 'n/a' : user,
      'date': date == null ? 'n/a' : date,
      'intDate': intDate == null ? 'n/a' : intDate,
      'deliveryDateRequired':
          deliveryDateRequired == null ? 'n/a' : deliveryDateRequired,
      'amount': amount,
      'description': description == null ? 'n/a' : description,
      'deliveryAddress': deliveryAddress == null ? 'n/a' : deliveryAddress,
      'purchaseOrderNumber': purchaseOrderNumber,
      'purchaseOrderURL': purchaseOrderURL == null ? 'n/a' : purchaseOrderURL,
      'supplierName': supplierName,
      'purchaserName': purchaserName,
      'contractURL': contractURL == null ? 'n/a' : contractURL,
    };
    return map;
  }
}
