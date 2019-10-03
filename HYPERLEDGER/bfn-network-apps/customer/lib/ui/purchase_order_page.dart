import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:customer/customer_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PurchaseOrderPage extends StatefulWidget {
  final String url;

  PurchaseOrderPage(this.url);

  @override
  _PurchaseOrderPageState createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  FirebaseMessaging _fcm = FirebaseMessaging();

  PurchaseOrder purchaseOrder = PurchaseOrder();
  User user;
  Customer customer;
  Company company;
  Supplier supplier;
  String poNumber, amount;

  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
  }

  _getSupplier() async {
    supplier = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SupplierSelectorPage()),
    );
    if (supplier == null) {
      AppSnackbar.showErrorSnackbar(
          listener: this,
          scaffoldKey: _scaffoldKey,
          message: 'No supplier found',
          actionLabel: 'Close');
    }
    print('_PurchaseOrderPageState._getSupplier ${supplier.toJson()}');
    setState(() {});
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    if (user != null) {
      userName = user.firstName + ' ' + user.lastName;
    }
    customer = await SharedPrefs.getCustomer();
    assert(customer != null);

    name = customer.name;

    setState(() {});
  }

  _submitPurchaseOrder() async {
    print('_PurchaseOrderPageState._registerPurchaseOrder .........');
    Navigator.pop(context);
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (customer != null) {
        purchaseOrder.customer = customer.participantId;
        purchaseOrder.purchaserName = customer.name;
        label = 'Govt';
      }

      if (supplier != null) {
        purchaseOrder.supplier = supplier.participantId;
        purchaseOrder.supplierName = supplier.name;
      }
      if (user != null) {
        if (user.userId != null) {
          purchaseOrder.user = user.userId;
        }
      }
      print(
          '_PurchaseOrderPageState._registerPurchaseOrder ... ${purchaseOrder.toJson()}');
      purchaseOrder.date = getUTCDate();
      purchaseOrder.amount = double.parse(amount);
      purchaseOrder.purchaseOrderNumber = poNumber;

      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Registering purchase order',
          textColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade700);
      //todo - check if this PO exists
      var po = await DataAPI3.addPurchaseOrder(purchaseOrder);
      print('_PurchaseOrderPageState._submitPurchaseOrder $po');
      _scaffoldKey.currentState.hideCurrentSnackBar();
      if (po == null) {
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Error submitting purchase order',
            actionLabel: 'close');
      } else {
        AppSnackbar.showSnackbarWithAction(
            scaffoldKey: _scaffoldKey,
            message: 'Purchase Order registered',
            textColor: Colors.white,
            actionLabel: 'Done',
            listener: this,
            icon: Icons.done,
            action: 1,
            backgroundColor: Colors.teal.shade700);
      }
    }
  }

  _confirm() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Confirm Purchase Order"),
              content: new Text("Do you want to submit this Purchase Order?"),
              actions: <Widget>[
                FlatButton(
                  onPressed: _cancel,
                  child: Text(
                    'NO',
                    style: style,
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 16.0),
                  child: FlatButton(
                    onPressed: _submitPurchaseOrder,
                    child: Text(
                      'YES',
                      style: style,
                    ),
                  ),
                ),
              ],
            ));
  }

  var style = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    fontSize: 16.0,
  );
  var style2 = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16.0,
  );
  var style3 = TextStyle(
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontSize: 12.0,
  );
  var name, userName, label = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('$label Purchase Order'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Column(
            children: <Widget>[
              Text(
                name == null ? '' : name,
                style: style2,
              ),
              new Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  userName == null ? '' : userName,
                  style: style3,
                ),
              ),
              StreamBuilder<String>(
                stream: customerBloc.fcmStream,
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
        ),
      ),
      body: Form(
        key: _formKey,
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
                      child: new Opacity(
                        opacity: 0.4,
                        child: Text(
                          'Purchase Order Details',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    new Column(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0.0, top: 8.0),
                          child: RaisedButton(
                            onPressed: _getSupplier,
                            elevation: 8.0,
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              'Get Supplier for PO',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        new Padding(
                          padding:
                              const EdgeInsets.only(top: 18.0, bottom: 24.0),
                          child: Text(
                            supplier == null ? '' : supplier.name,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    TextFormField(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Purchase Order Number',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter PO number';
                        }
                      },
                      onSaved: (val) => poNumber = val,
                    ),
                    TextFormField(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the amount';
                        }
                      },
                      onSaved: (val) => amount = val,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 28.0, right: 20.0, top: 30.0),
                      child: RaisedButton(
                        elevation: 8.0,
                        color: Theme.of(context).accentColor,
                        onPressed: _confirm,
                        child: new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Submit Purchase Order',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _cancel() {
    print('_PurchaseOrderPageState._cancel CANCELLED confirm');
  }

  @override
  onActionPressed(int action) {
    print('_PurchaseOrderPageState.onActionPressed .......... Yay!!');
    switch (action) {
      case 1:
        Navigator.pop(context, purchaseOrder);
        break;
    }
  }

  @override
  onDeliveryNoteMessage(DeliveryNote deliveryNote) {
    _showSnack('Delivery Note has arrived', Colors.lime);
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    _showSnack('Invoice has arrived', Colors.white);
  }

  void _showSnack(String message, Color textColor) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: textColor,
        backgroundColor: Styles.black);
  }
}
