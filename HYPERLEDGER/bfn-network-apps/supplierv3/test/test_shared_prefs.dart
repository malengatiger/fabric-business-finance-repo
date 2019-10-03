import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('test SharedPrefs returns saved data', () async {
    Supplier supplier = Supplier(
      participantId: '97979dhdlyo96db',
      name: 'Aubrey M',
    );
    SharedPreferences.setMockInitialValues({}); //set values here
    SharedPreferences pref = await SharedPreferences.getInstance();
    String participantId = supplier.participantId;
    String name = supplier.name;
    pref.setString('participantId', participantId);
    pref.setString('name', name);

    expect(pref.getString('participantId'), supplier.participantId);
    expect(pref.getString('name'), supplier.name);
  });

  test('app model getTotalOpenOffers', () async {
    SupplierApplicationModel model = SupplierApplicationModel();
    PurchaseOrder order = PurchaseOrder(
      purchaseOrderId: '9969gghlyhky956',
      purchaseOrderNumber: 'PO537382',
      amount: 100.00,
    );
    Invoice invoice = Invoice(invoiceId: '93973', amount: 800.00, valueAddedTax: 120.00, totalAmount: 920.00);

    //await model.addPurchaseOrder(order);
    //await model.addInvoice(invoice);

    expect(model.getTotalPurchaseOrders(), 0);
    expect(model.getTotalOpenOfferAmount(), 0.0);
    expect(model.invoices.length, 0);
    expect(model.listener, null);

  });
  test('ListAPI', () async {
    var m = await ListAPI.getAutoTradeOrders();
  });
}
