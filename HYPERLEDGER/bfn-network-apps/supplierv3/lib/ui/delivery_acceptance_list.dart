import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class DeliveryAcceptanceList extends StatefulWidget {
  @override
  _DeliveryAcceptanceListState createState() => _DeliveryAcceptanceListState();
}

class _DeliveryAcceptanceListState extends State<DeliveryAcceptanceList>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();

  List<DeliveryAcceptance> acceptances;
  DeliveryAcceptance deliveryAcceptance;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryAcceptance;
  FCM _fm = FCM();
  DeliveryAcceptance acceptance;

  @override
  void initState() {
    super.initState();
    _getAcceptances();
  }

  _getAcceptances() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();

    setState(() {});
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading delivery note acceptances',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    print('_DeliveryAcceptanceListState._getAcceptances ... calling api');
    acceptances = await ListAPI.getDeliveryAcceptances(
        participantId: supplier.participantId, participantType: 'supplier');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    setState(() {});
    if (acceptances.isEmpty) {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'No delivery acceptances',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'Close',
          listener: this,
          action: 1,
          icon: Icons.error);
    }
  }

  _confirm() {
    print('_DeliveryAcceptanceListState._confirm');
    prettyPrint(acceptance.toJson(), '_DeliveryAcceptanceListState._confirm');
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Actions",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Delivery Acceptance: ${acceptance.customerName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                        'Do you want to create an Invoice based on this Delivery Acceptance?'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'NO',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    onPressed: _onInvoiceToCreate,
                    elevation: 4.0,
                    color: Colors.amber.shade300,
                    child: Text(
                      'Create Invoice',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ));
  }

  _onInvoiceToCreate() {
    print(
        '_DeliveryAcceptanceListState._onInvoiceToCreate ... go to NewInvoicePage');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new NewInvoicePage(acceptance)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Acceptances'),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    supplier == null ? '' : supplier.name,
                    style: getTitleTextWhite(),
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
            preferredSize: Size.fromHeight(60.0)),
      ),
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: acceptances == null ? 0 : acceptances.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        acceptance = acceptances.elementAt(index);
                        _confirm();
                      },
                      child: DeliveryAcceptanceCard(
                        deliveryAcceptance: acceptances.elementAt(index),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  onActionPressed(int action) {
    print('_DeliveryAcceptanceListState.onActionPressed');
    Navigator.pop(context);
  }

  @override
  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance) {
    _showSnack('Delivery Note accepted', Styles.lightBlue);
  }

  @override
  onInvoiceAcceptanceMessage(InvoiceAcceptance acceptance) {
    _showSnack('Invoice Acceptance arrived', Styles.lightBlue);
  }

  void _showSnack(String message, Color color) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: color,
        backgroundColor: Styles.black);
  }
}

class DeliveryAcceptanceCard extends StatelessWidget {
  final DeliveryAcceptance deliveryAcceptance;

  DeliveryAcceptanceCard({this.deliveryAcceptance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.event,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  getFormattedDate(deliveryAcceptance.date),
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    deliveryAcceptance.customerName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
