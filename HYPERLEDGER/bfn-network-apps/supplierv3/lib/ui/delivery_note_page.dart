import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class DeliveryNotePage extends StatefulWidget {
  final PurchaseOrder purchaseOrder;

  DeliveryNotePage(this.purchaseOrder);

  @override
  _DeliveryNotePageState createState() => _DeliveryNotePageState();
}

class _DeliveryNotePageState extends State<DeliveryNotePage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  PurchaseOrder _purchaseOrder;
  List<PurchaseOrder> _purchaseOrders;
  User _user;
  String userName;
  Supplier supplier;
  FCM _fm = FCM();

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  _getCached() async {
    _user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    userName = _user.firstName + ' ' + _user.lastName;

    if (widget.purchaseOrder == null) {
      _getPurchaseOrders();
    }
  }

  void _getPurchaseOrders() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading  purchase orders',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black);
    _purchaseOrders =
        await ListAPI.getSupplierPurchaseOrders(supplier.participantId);
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    setState(() {});
  }

  var styleLabels = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  var styleBlack = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  var styleBlue = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w900,
    color: Colors.blue.shade700,
  );
  var styleTeal = TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.w900,
    color: Colors.teal.shade700,
  );

  SupplierApplicationModel appModel;
  List<DropdownMenuItem<PurchaseOrder>> items = List();
  Widget _getPOList() {
    if (_purchaseOrders == null) {
      return Container();
    }

    items.clear();
    var index = 0;
    _purchaseOrders.forEach((po) {
      var item6 = DropdownMenuItem<PurchaseOrder>(
        value: po,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
            ),
            Text(
              '${po.purchaserName}',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      );

      items.add(item6);
    });
    return DropdownButton<PurchaseOrder>(
      items: items,
      onChanged: _onPOpicked,
      elevation: 8,
      hint: Text(
        'Purchase Orders',
        style: TextStyle(fontSize: 16.0, color: Colors.blue),
      ),
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: new Column(
        children: <Widget>[
          Text(
            _purchaseOrder == null ? '' : _purchaseOrder.supplierName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0),
          ),
          new Container(
            child: new Padding(
              padding: const EdgeInsets.only(bottom: 18.0, top: 10.0),
              child: Text(
                userName == null ? '' : userName,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 14.0),
              ),
            ),
          ),
          StreamBuilder<String>(
            stream: supplierBloc.fcmStream,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      snapshot.data,
                      style: Styles.whiteSmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.purchaseOrder != null) {
      _purchaseOrder = widget.purchaseOrder;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Create Delivery Note',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        bottom: _getBottom(),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 20.0),
            child: ListView(
              children: <Widget>[
                _getPOList(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                  child: Text(
                    _purchaseOrder == null ? '' : _purchaseOrder.purchaserName,
                    style: styleBlack,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Purchase Order:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder == null
                            ? ''
                            : _purchaseOrder.purchaseOrderNumber,
                        style: styleBlack,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'PO Date:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder == null
                            ? ''
                            : getFormattedDateShort(
                                '${_purchaseOrder.date}', context),
                        style: styleBlack,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'PO Amt:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder == null ? '0.00' : _getFormattedAmount(),
                        style: styleTeal,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Total Invoiced:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        totalPOInvoiceAmt == null ? '0.00' : totalPOInvoiceAmt,
                        style: styleBlue,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: TextField(
                    onChanged: _onAmountChanged,
                    maxLength: 20,
                    style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: 'Delivery Note Amount',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 20.0)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Delivery Note VAT',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          vat == null
                              ? '0.00'
                              : getFormattedAmount(vat, context),
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    right: 20.0,
                  ),
                  child: RaisedButton(
                    elevation: 8.0,
                    color: Colors.indigo.shade300,
                    onPressed: _onSubmit,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Submit Delivery Note',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedAmount() {
    final oCcy = new NumberFormat("#,##0.00", "en_ZA");
    double m = _purchaseOrder.amount;
    return oCcy.format(m);
  }

  void _onSubmit() async {
    print('_DeliveryNotePageState._onSubmit');
    if (amount == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Missing amount',
          listener: this,
          actionLabel: 'Fix');
      return;
    }

    ///check invoices made oon this PO
    double total = 0.00;
    invoices.forEach((m) {
      print(
          '_DeliveryNotePageState._onSubmit ++++++++++++ adding ${m.amount} to total: $total');
      total += m.amount;
    });
    print(
        '_DeliveryNotePageState._onSubmit ++++++++++++ adding $amount to total: $total');
    total += double.parse(amount);
    print(
        '_DeliveryNotePageState._onSubmit ++++++++++++ total $total > purchaseOrder.amount:  ${_purchaseOrder.amount}');
    if (total > _purchaseOrder.amount) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Purchase Order amount exceeded',
          listener: this,
          actionLabel: 'close');
      return;
    }
    var note = DeliveryNote(
      purchaseOrder: _purchaseOrder.purchaseOrderId,
      supplier: _purchaseOrder.supplier,
      supplierName: _purchaseOrder.supplierName,
      user: _user.userId,
      date: DateTime.now().toIso8601String(),
      purchaseOrderNumber: _purchaseOrder.purchaseOrderNumber,
      customerName: _purchaseOrder.purchaserName,
      amount: double.parse(amount),
      vat: double.parse(vat),
      totalAmount: double.parse(totalAmount),
    );
    if (_purchaseOrder.customer != null) {
      note.customer = _purchaseOrder.customer;
    }

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Delivery Note ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    try {
      await DataAPI3.addDeliveryNote(note);
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Note submitted',
          textColor: Colors.white,
          backgroundColor: Colors.teal.shade800,
          actionLabel: 'DONE',
          action: 0,
          listener: this,
          icon: Icons.done);
      isDone = true;

      await supplierBloc.refreshModel();
    } catch (e) {
      print(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Note submission failed',
          listener: this,
          actionLabel: 'Close');
    }
  }

  bool isDone = false;
  List<Invoice> invoices = List();
  String totalPOInvoiceAmt;
  @override
  onActionPressed(int action) {
    print('_DeliveryNotePageState.onActionPressed ............');

    switch (action) {
      case 1:
        Navigator.pop(context);
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new NewInvoicePage(deliveryAcceptance)),
        );
        break;
      default:
        Navigator.pop(context, isDone);
        break;
    }
  }

  void _onPOpicked(PurchaseOrder value) async {
    prettyPrint(value.toJson(), '🌼 🌼 DeliveryNotePageState._onPOpicked: ');
    _purchaseOrder = value;
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Gettting PO invoices ...',
        textColor: Styles.lightBlue,
        backgroundColor: Styles.black);
    invoices = await ListAPI.getInvoicesByPurchaseOrder(
        _purchaseOrder.purchaseOrderId, supplier.participantId);
    _scaffoldKey.currentState.removeCurrentSnackBar();
    double total = 0.00;
    invoices.forEach((m) {
      print(
          '_DeliveryNotePageState._onPOpicked adding ${m.amount} to total: $total PO: ${_purchaseOrder.purchaseOrderNumber}');
      total += m.amount;
    });
    totalPOInvoiceAmt = '${getFormattedAmount('$total', context)}';

    print('_DeliveryNotePageState._onPOpicked - invoices for PurchaseOrder:'
        '${_purchaseOrder.purchaseOrderNumber}, invoices: ${invoices.length} total: $totalPOInvoiceAmt');
    setState(() {});
  }

  String amount, vat, totalAmount;

  void _onAmountChanged(String value) {
//    print('_DeliveryNotePageState._amtChanged: $value');
    amount = value;
    //todo - internationalize
    double amt = double.parse(amount);
    double xvat = amt * 0.15;
    double tot = amt + xvat;
    vat = xvat.toString();
    totalAmount = tot.toString();
    setState(() {});
//    print(
//        '_DeliveryNotePageState._onAmountChanged vat: $vat tottal: $totalAmount');
  }

  DeliveryAcceptance deliveryAcceptance;
  @override
  onDeliveryAcceptance(DeliveryAcceptance da) {}

  @override
  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance) {
    deliveryAcceptance = acceptance;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Acceptance arrived',
        textColor: Styles.white,
        backgroundColor: Styles.blue,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.done,
        action: 1);
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order arrived',
        textColor: Styles.white,
        backgroundColor: Styles.blue,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.done,
        action: 1);
  }
}
