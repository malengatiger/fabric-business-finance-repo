import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';

class InvoiceBids extends StatefulWidget {
  final OfferBag offerBag;

  InvoiceBids(this.offerBag);

  @override
  _InvoiceBidsState createState() => _InvoiceBidsState();
}

class _InvoiceBidsState extends State<InvoiceBids> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  static const MakeOffer = '1', CancelOffer = '2', EditInvoice = '3';
  List<InvoiceBid> invoiceBids;

  InvoiceBid invoiceBid;
  Offer offer;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isInvoice;
  List<DropdownMenuItem<String>> items = List();

  @override
  void initState() {
    super.initState();

    _getCached();
    _getInvoiceBids();
  }

  _showMenuDialog(InvoiceBid invoiceBid) {
    this.invoiceBid = invoiceBid;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Bid Actions",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 240.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Investor: ${invoiceBid.investorName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildItems(),
                  ],
                ),
              ),
            ));
  }

  _onInvoiceDetails() {
//    Navigator.push(
//      context,
//      new MaterialPageRoute(
//          builder: (context) => new InvoiceDetailsPage(invoiceBid)),
//    );
  }

  Widget _buildItems() {
    var item1 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onOffer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.attach_money,
                color: Colors.green.shade800,
              ),
            ),
            Text('Make Invoice Offer'),
          ],
        ),
      ),
    );
    var item2 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _cancelOffer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.cancel,
                color: Colors.red.shade800,
              ),
            ),
            Text('Cancel Invoice Offer'),
          ],
        ),
      ),
    );
    var item3 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onInvoiceDetails,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.description,
                color: Colors.blue.shade800,
              ),
            ),
            Text('View Invoice Details'),
          ],
        ),
      ),
    );

    return Column(
      children: <Widget>[
        item1,
        item2,
        item3,
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            ),
          ),
        ),
      ],
    );
  }

  _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    setState(() {});
  }

  _getInvoiceBids() async {
    invoiceBids = widget.offerBag.invoiceBids;
    offer = widget.offerBag.offer;
    _calculateTotal();
  }

  void _calculateTotal() {
    if (invoiceBids.isNotEmpty) {
      double total = 0.00;
      invoiceBids.forEach((inv) {
        double amt = inv.amount;
        total += amt;
      });

      totalAmount = getFormattedAmount('$total', context);
    }
    setState(() {});
  }

  String totalAmount;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoices'),
        elevation: 8.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onInvoiceAdd,
          ),
        ],
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    supplier == null ? 'Blank Supplier?' : supplier.name,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 20.0, top: 10.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          totalAmount == null ? '0.00' : totalAmount,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(110.0)),
      ),
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: invoiceBids == null ? 0 : invoiceBids.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        _showMenuDialog(invoiceBids.elementAt(index));
                      },
                      child: InvoiceBidCard(
                        bid: invoiceBids.elementAt(index),
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
    print('_InvoiceBidsState.onActionPressed');
  }

  void _onOffer() {
    print('_InvoiceBidsState._onOffer');
    Navigator.pop(context);
//    Navigator.push(
//      context,
//      new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoiceBid)),
//    );
  }

  void _cancelOffer() {
    print('_InvoiceBidsState._cancelOffer ..........');
  }

  void _onInvoiceAdd() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DeliveryAcceptanceList()),
    );
  }

  @override
  onInvoiceAcceptanceMessage(InvoiceAcceptance acc) {
    print('_InvoiceBidsState.onInvoiceAcceptance');
    _showSnack('Invoice Acceptance arrived', Colors.lightBlue);
  }

  @override
  onInvoiceBidMessage(InvoiceBid bid) {
    print('_InvoiceBidsState.onInvoiceBidMessage');
    _showSnack('Invoice Bid arrived', Colors.yellow);
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder order) {
    print('_InvoiceBidsState.onPurchaseOrderMessage');
    _showSnack('Purchase Order arrived', Colors.white);
  }

  _showSnack(String message, Color textColor) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: textColor,
        backgroundColor: Colors.black);
  }
}
