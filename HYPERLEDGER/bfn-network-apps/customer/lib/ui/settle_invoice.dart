import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/webview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/customer_bloc.dart';
import 'package:customer/ui/settlements.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SettleInvoice extends StatefulWidget {
  final Invoice invoice;
  final OfferBag offerBag;
  SettleInvoice({this.invoice, this.offerBag});

  @override
  _SettleInvoice createState() => _SettleInvoice();
}

class _SettleInvoice extends State<SettleInvoice> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging fm = FirebaseMessaging();
  final Firestore fs = Firestore.instance;
  CustomerApplicationModel appModel;
  String webViewTitle, webViewUrl;
  Offer offer;
  OfferBag offerBag;
  PaymentKey paymentKey;
  double bottomHeight = 20.0;
  bool isBusy = false;
  User user;
  Customer customer;
  double totalBidAmount = 0.00;
  double avgDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    _getCache();
    appModel = customerBloc.appModel;
  }

  void _getCache() async {
    user = await SharedPrefs.getUser();
    customer = await SharedPrefs.getCustomer();
  }

  StreamSubscription<QuerySnapshot> streamSub, streamTrans;
  void _listenForSettlement() async {
    print(
        '_SettleInvoice._listenForSettlements .................paymentKey.key: ${paymentKey.key} ........');
    Query reference = fs
        .collection('settlements')
        .where('peachPaymentKey', isEqualTo: paymentKey.key);

    streamSub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        // Do something with change
        if (change.type == DocumentChangeType.added) {
          var settlement =
              InvestorInvoiceSettlement.fromJson(change.document.data);
          if (settlement.peachPaymentKey == paymentKey.key) {
            prettyPrint(settlement.toJson(),
                '\n\n_SettleInvoice._listenForSettlement- ############### DocumentChangeType = added, settlement received:\n');
            print('_SettleInvoice._listen about to call streamSub.cancel();');
            settlements.add(settlement);
            if (widget.invoice != null) {
              streamSub.cancel();
              _updateModel();
            }
          } else {
            print(
                '_SettleInvoice._listenForSettlements - this is NOT our settlement - IGNORE!');
          }
        }
      });
    });
  }

  List<InvestorInvoiceSettlement> settlements = List();
  void _listenForTransaction() async {
    print(
        '_SettleInvoice._listenForTransaction.................paymentKey.key: ${paymentKey.key} ........');
    Query reference = fs
        .collection('peachTransactions')
        .where('payment_key', isEqualTo: paymentKey.key);

    streamTrans = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          if (change.document.data['payment_key'] == paymentKey.key) {
            prettyPrint(change.document.data,
                '\n\n_SettleInvoice._listenForTransaction - ############### PEACH PAYMENTS transaction received:');
            print(
                '_SettleInvoice.__listenForTransaction about to call streamTrans.cancel();');
            streamTrans.cancel();
            _showSnackRegistered();
          } else {
            print(
                '_SettleInvoice.__listenForTransaction- this is NOT our PEACH PAYMENTS transaction - IGNORE!');
          }
        }
      });
    });
  }

  void _updateModel() async {
    if (widget.invoice != null) {
      await customerBloc.refreshModel();
      setState(() {});
    }
  }

  void _showSnackRegistered() async {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Payment registered',
        textColor: Colors.white,
        action: Exit,
        listener: this,
        icon: Icons.done_all,
        actionLabel: 'Done',
        backgroundColor: Colors.teal);
  }

  int count = 0;
  void _showWebView() async {
    if (isBusy) {
      print('_SettleInvoice._showWebView isBusy $isBusy');
      return;
    }
    isBusy = true;
    try {
      int result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BFNWebView(
                  title: webViewTitle,
                  url: webViewUrl,
                )),
      );
      switch (result) {
        case PeachSuccess:
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Payment successful\nWait for registration ...',
              textColor: Styles.white,
              backgroundColor: Colors.indigo.shade400,
              actionLabel: 'Wait',
              listener: this,
              icon: Icons.done,
              action: 0);

          setState(() {
            isBusy = false;
          });

          break;
        case PeachCancel:
          isBusy = false;
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Payment cancelled',
              textColor: Styles.white,
              backgroundColor: Colors.blueGrey.shade500,
              actionLabel: 'OK',
              listener: this,
              icon: Icons.clear,
              action: PeachCancel);
          break;
        case PeachError:
          isBusy = false;
          AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'There was an error making the payment',
            actionLabel: 'Close',
            listener: this,
          );
          break;
      }
    } catch (e) {
      print(e);
      print('_SettleInvoice._showWebView --- webview FUCKED!');
    }
  }

  double totAmt = 0.0;
  Future _getPaymentKey() async {
    if (isBusy) {
      return;
    }
    print('\n_SettleInvoice._getPaymentKey ............................');
    var ref;
    totAmt = 0.00;
    if (widget.invoice != null) {
      totAmt = widget.invoice.totalAmount;
      ref = widget.invoice.invoiceId;
    }

    var payment = PeachPayment(
      merchantReference: ref,
      amount: totAmt,
//      successURL: getFunctionsURL() + 'peachSuccess',
//      cancelUrl: getFunctionsURL() + 'peachCancel',
//      errorUrl: getFunctionsURL() + 'peachError',
//      notifyUrl: getFunctionsURL() + 'peachNotify',
    );
    prettyPrint(payment.toJson(),
        '##### getPaymentKey - payment, check merchant reference');
    try {
      paymentKey = await Peach.getPaymentKey(payment: payment);
      if (paymentKey != null) {
        print(
            '\n\n_SettleInvoice._getPaymentKey ########### paymentKey: ${paymentKey.key} ${paymentKey.url}');
        webViewTitle = 'Your Bank Login';
        webViewUrl = paymentKey.url;
        _listenForSettlement();
        _listenForTransaction();
        _showWebView();
      } else {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Error starting bank login',
            listener: this,
            actionLabel: 'Close');
      }
    } catch (e) {
      print(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Error starting bank process',
          listener: this,
          actionLabel: 'Close');
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                '${widget.invoice.supplierName}',
                style: Styles.whiteBoldMedium,
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                    width: 100.0,
                    child: Text(
                      'Invoice Bids',
                      style: Styles.whiteSmall,
                    )),
                Text(
                  '${widget.offerBag.invoiceBids.length}',
                  style: Styles.whiteBoldLarge,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: 100.0,
                      child: Text(
                        'Offer Amount',
                        style: Styles.whiteSmall,
                      )),
                  Text(
                    '${getFormattedAmount('${widget.offerBag.offer.offerAmount}', context)}',
                    style: Styles.blackBoldLarge,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: 100.0,
                      child: Text(
                        'Offer Date',
                        style: Styles.whiteSmall,
                      )),
                  Text(
                    getFormattedDateShortWithTime(
                        widget.offerBag.offer.date, context),
                    style: Styles.whiteSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: 100.0,
                      child: Text(
                        'Discount',
                        style: Styles.whiteSmall,
                      )),
                  Text(
                    '${widget.offerBag.offer.discountPercent.toStringAsFixed(2)} %',
                    style: Styles.whiteBoldSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool willBeChecking = true;
  static const int Exit = 1;
  String text =
      'The totals below represent the total amount of invoice bids made by you or by the BFN Network. A single payment will be made for all outstanding bids.';

  Widget _getBody() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: InvoiceCard(
            invoice: widget.invoice,
            elevation: 2.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Center(
            child: RaisedButton(
              elevation: 16.0,
              onPressed: _getPaymentKey,
              color: Colors.pink.shade400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Settle Invoice ',
                  style: Styles.whiteSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Settlement'),
        bottom: _getBottom(),
        elevation: 2.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _onRefreshPressed,
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: _getBody(),
    );
  }

  @override
  onActionPressed(int action) {
    print('_SettleInvoice.onActionPressed action: $action');
    switch (action) {
      case PeachSuccess:
        Navigator.pop(context);
        break;
      case PeachCancel:
        break;
      case PeachError:
        break;
      case Exit:
        _scaffoldKey.currentState.removeCurrentSnackBar();
        print('_SettleInvoice.onActionPressed about to pop .....');
        Navigator.pop(context, true);
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => SettlementList()),
        );
        break;
      case 2:
        break;
      default:
        break;
    }
  }

  void _onRefreshPressed() {}

  String _getTotalBidAmount() {
    var t = 0.00;
    offerBag.invoiceBids.forEach((bid) {
      t += bid.amount;
    });

    return getFormattedAmount('$t', context);
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final double elevation;
  final Color color;

  InvoiceCard({this.invoice, this.elevation, this.color});

  @override
  Widget build(BuildContext context) {
    if (invoice == null) {
      return Center(
        child: Text('Invoice loading ..'),
      );
    }
    return Card(
      elevation: elevation == null ? 2.0 : elevation,
      color: color == null ? Colors.white : color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 100.0,
                  child: Text(
                    'Invoice Date:',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  getFormattedDateShortWithTime(invoice.date, context),
                  style: Styles.blueBoldSmall,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 80.0,
                    child: Text(
                      'Supplier',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Flexible(
                      child: Container(
                          child: Text(
                    '${invoice.supplierName}',
                    style: Styles.blackBoldMedium,
                    overflow: TextOverflow.ellipsis,
                  )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 80.0,
                    child: Text(
                      'Customer',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Text(
                    '${invoice.customerName}',
                    style: Styles.blackBoldSmall,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 80.0,
                    child: Text(
                      'Amount',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Text(
                    '${getFormattedAmount('${invoice.amount}', context)}',
                    style: Styles.blackBoldMedium,
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 80.0,
                  child: Text(
                    'VAT',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  '${getFormattedAmount('${invoice.valueAddedTax}', context)}',
                  style: Styles.greyLabelMedium,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 80.0,
                    child: Text(
                      'Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Text(
                    '${getFormattedAmount('${invoice.totalAmount}', context)}',
                    style: Styles.tealBoldLarge,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
