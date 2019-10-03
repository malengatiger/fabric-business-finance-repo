import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/investor_model_bloc.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/webview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/bloc/bloc.dart';
import 'package:investor/ui/unsettled_bids.dart';

class SettleInvoiceBid extends StatefulWidget {
  final InvoiceBid invoiceBid;
  final List<InvoiceBid> invoiceBids;
  SettleInvoiceBid({this.invoiceBid, this.invoiceBids});

  @override
  _SettleInvoiceBid createState() => _SettleInvoiceBid();
}

class _SettleInvoiceBid extends State<SettleInvoiceBid>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging fm = FirebaseMessaging();
  final Firestore fs = Firestore.instance;
  InvestorAppModel appModel;
  String webViewTitle, webViewUrl;
  Offer offer;
  OfferBag offerBag;
  PaymentKey paymentKey;
  double bottomHeight = 20.0;
  bool isBusy = false;
  User user;
  Investor investor;
  double totalBidAmount = 0.00;
  double avgDiscount = 0.0;
  FCM _fcm = FCM();
  @override
  void initState() {
    super.initState();
    _getCache();
    appModel = investorModelBloc.appModel;
    _getOffers();
  }

  void _getCache() async {
    user = await SharedPrefs.getUser();
    investor = await SharedPrefs.getInvestor();
  }

  StreamSubscription<QuerySnapshot> streamSub, streamTrans;
  void _listenForSettlement() async {
    print(
        '_SettleInvoiceBid._listenForSettlements .................paymentKey.key: ${paymentKey.key} ........');
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
                '\n\n_SettleInvoiceBid._listenForSettlement- ############### DocumentChangeType = added, settlement received:\n');
            print(
                '_SettleInvoiceBid._listen about to call streamSub.cancel();');
            settlements.add(settlement);
            if (widget.invoiceBid != null) {
              streamSub.cancel();
              _updateModel();
            } else {
              if (settlements.length == widget.invoiceBids.length) {
                streamSub.cancel();
                _updateModel();
              }
            }
          } else {
            print(
                '_SettleInvoiceBid._listenForSettlements - this is NOT our settlement - IGNORE!');
          }
        }
      });
    });
  }

  List<InvestorInvoiceSettlement> settlements = List();
  void _listenForTransaction() async {
    print(
        '_SettleInvoiceBid._listenForTransaction.................paymentKey.key: ${paymentKey.key} ........');
    Query reference = fs
        .collection('peachTransactions')
        .where('payment_key', isEqualTo: paymentKey.key);

    streamTrans = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          if (change.document.data['payment_key'] == paymentKey.key) {
            prettyPrint(change.document.data,
                '\n\n_SettleInvoiceBid._listenForTransaction - ############### PEACH PAYMENTS transaction received:');
            print(
                '_SettleInvoiceBid.__listenForTransaction about to call streamTrans.cancel();');
            streamTrans.cancel();
            _showSnackRegistered();
          } else {
            print(
                '_SettleInvoiceBid.__listenForTransaction- this is NOT our PEACH PAYMENTS transaction - IGNORE!');
          }
        }
      });
    });
  }

  void _updateModel() async {
    if (widget.invoiceBid != null) {
      await appModel.processSettledBid(widget.invoiceBid);
      await appModel.refreshDashboard();
    }
    if (widget.invoiceBids != null) {
      for (var bid in widget.invoiceBids) {
        await appModel.processSettledBid(bid);
      }
      await appModel.refreshDashboard();
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
  Future _getOffers() async {
    count++;
    setState(() {
      isBusy = true;
      if (count > 1) {
        bottomHeight = 200.0;
      }
    });
    if (widget.invoiceBid != null) {
      if (widget.invoiceBid.offer == null) {
        prettyPrint(
            widget.invoiceBid.toJson(), '\n\n########## checking offerDocRef');
        throw Exception('Missing offerDocRef in invoiceBid');
      }
      offerBag = await ListAPI.getOfferById(widget.invoiceBid.offer);
      setState(() {
        isBusy = false;
      });
      if (offerBag != null) {
        offerBag.doPrint();
        offer = offerBag.offer;

        setState(() {
          bottomHeight = 160.0;
          willBeChecking = false;
        });
      }
    } else {
      setState(() {
        willBeChecking = false;
      });
    }
    isBusy = false;
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
  }

  void _showWebView() async {
    if (isBusy) {
      print('_SettleInvoiceBid._showWebView isBusy $isBusy');
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
      print('_SettleInvoiceBid._showWebView --- webview FUCKED!');
    }
  }

  double totAmt = 0.0;
  Future _getPaymentKey() async {
    if (isBusy) {
      return;
    }
    print('\n_SettleInvoiceBid._getPaymentKey ............................');
    var ref;
    totAmt = 0.00;
    if (widget.invoiceBid != null) {
      totAmt = widget.invoiceBid.amount;
      ref = widget.invoiceBid.invoiceBidId;
    } else {
      widget.invoiceBids.forEach((b) {
        totAmt += b.amount;
      });
      ref = await DataAPI3.writeMultiKeys(widget.invoiceBids);
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
            '\n\n_MyHomePageState._getPaymentKey ########### paymentKey: ${paymentKey.key} ${paymentKey.url}');
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
      preferredSize: Size.fromHeight(bottomHeight),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: offerBag == null
            ? Container()
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Invoice Bids:',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${offerBag.invoiceBids.length}',
                            style: Styles.whiteBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Offer Amount:',
                          style: Styles.whiteSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${getFormattedAmount('${offerBag.offer.offerAmount}', context)}',
                          style: Styles.whiteBoldMedium,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Bids Made:',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            _getTotalBidAmount(),
                            style: Styles.blackBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 16.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Offer Expiry:',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${getFormattedDate(offerBag.offer.endTime)}',
                            style: Styles.whiteBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isBusy == false
                      ? Container()
                      : Container(
                          height: 28.0,
                          width: 28.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 6.0,
                            ),
                          ),
                        ),
                  StreamBuilder<String>(
                    stream: investorBloc.fcmStream,
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
          padding: const EdgeInsets.all(8.0),
          child: widget.invoiceBids == null
              ? InvoiceBidCard(
                  bid: widget.invoiceBid,
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          text,
                          style: Styles.blackBoldSmall,
                        ),
                      ),
                      InvoiceBidsCard(
                        bids: widget.invoiceBids,
                      ),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: willBeChecking == true
              ? Row(
                  children: <Widget>[
                    Text(
                      'Checking Bids. Please wait ...',
                      style: Styles.blackBoldMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        height: 16.0,
                        width: 16.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 6.0,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
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
                  widget.invoiceBids == null
                      ? 'Settle Invoice Bid'
                      : 'Settle ${widget.invoiceBids.length} Invoice Bids',
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
        title: Text('Invoice Bid Settlement'),
        bottom: _getBottom(),
        elevation: 2.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getOffers,
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: _getBody(),
    );
  }

  @override
  onActionPressed(int action) {
    print('_SettleInvoiceBid.onActionPressed action: $action');
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
        print('_SettleInvoiceBid.onActionPressed about to pop .....');
        Navigator.pop(context, true);
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => UnsettledBids()),
        );
        break;
      case 2:
        break;
      default:
        break;
    }
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print('_SettleInvoiceBid.onInvoiceBidMessage - bid arrived for this offer');
    offerBag.invoiceBids.insert(0, invoiceBid);
    setState(() {});
  }

  String _getTotalBidAmount() {
    var t = 0.0;
    offerBag.invoiceBids.forEach((bid) {
      t += bid.amount;
    });

    return getFormattedAmount('$t', context);
  }

  @override
  onInvestorInvoiceSettlement(InvestorInvoiceSettlement settlement) async {
    prettyPrint(
        settlement.toJson(), '\n\n ################ settlement arrived:');
    _showSnackRegistered();
    await investorModelBloc.refreshDashboard();
    return null;
  }
}
