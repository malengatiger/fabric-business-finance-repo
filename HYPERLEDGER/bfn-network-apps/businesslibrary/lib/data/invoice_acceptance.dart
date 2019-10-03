import 'package:businesslibrary/util/Finders.dart';

class InvoiceAcceptance extends Findable {
  String acceptanceId;
  String supplierName;
  String customerName;
  String invoiceNumber;
  String date;
  String invoice;
  String customer, supplier;
  String user;

  InvoiceAcceptance(
      {this.acceptanceId,
      this.supplierName,
      this.customerName,
      this.invoiceNumber,
      this.date,
      this.invoice,
      this.supplier,
      this.customer,
      this.user});

  InvoiceAcceptance.fromJson(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.invoice = data['invoice'];
    this.customer = data['customer'];
    this.user = data['user'];
    this.date = data['date'];
    this.invoiceNumber = data['invoiceNumber'];
    this.supplier = data['supllier'];
    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'acceptanceId': acceptanceId == null ? 'n/a' : acceptanceId,
        'invoice': invoice,
        'invoiceNumber': invoiceNumber == null ? 'n/a' : invoiceNumber,
        'customer': customer,
        'user': user == null ? 'n/a' : user,
        'date': date == null ? 'n/a' : date,
        'supplierName': supplierName,
        'supplier': supplier,
        'customerName': customerName,
      };
}
