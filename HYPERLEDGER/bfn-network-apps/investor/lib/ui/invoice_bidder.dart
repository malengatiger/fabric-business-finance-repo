import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/investor_model_bloc.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/offer_card.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/bloc/bloc.dart';
import 'package:investor/ui/invoice_due_diligence.dart';

class InvoiceBidder extends StatefulWidget {
  final Offer offer;
  final List<InvoiceBid> existingBids;

  InvoiceBidder({this.offer, this.existingBids});

  @override
  _InvoiceBidderState createState() => _InvoiceBidderState();
}

class _InvoiceBidderState extends State<InvoiceBidder>
    implements SnackBarListener, FCMListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  DateTime startTime, endTime;
  Investor investor;
  Offer offer;
  User user;
  Wallet wallet;
  bool _showBusyIndicator = false;
  InvestorAppModel appModel;
  @override
  void initState() {
    super.initState();
    appModel = investorModelBloc.appModel;
    print(
        '_InvoiceBidderState.initState ==================================>>>');
    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    user = await SharedPrefs.getUser();
    wallet = await SharedPrefs.getWallet();
    setState(() {});
    _getExistingBids();
  }

  void _getExistingBids() async {
    if (offer == null) return;
    setState(() {
      loadText = 'Loading existing bids ... if any';
      _showBusyIndicator = true;
    });
    offerBids = widget.existingBids;
    int cnt = 0;
    offerBids.forEach((b) {
      cnt++;
      prettyPrint(b.toJson(), 'InvoiceBid on the offer: #$cnt');
    });
    _calculateTotal();
    _buildPercChoices();
    setState(() {
      _showBusyIndicator = false;
    });
    prettyPrint(widget.offer.toJson(), '@@@@@@@@ offer:');
  }

  @override
  Widget build(BuildContext context) {
    if (offer == null) {
      offer = widget.offer;
      //_getExistingBids();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Make Invoice Bid',
          style: Styles.whiteBoldSmall,
        ),
        elevation: 8.0,
        backgroundColor: Colors.pink.shade300,
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _getExistingBids),
        ],
      ),
      body: _getBody(),
    );
  }

  double totalAmtBid = 0.00;
  double totalPercBid = 0.00;
  double totalToGo = 0.00;

  _calculateTotal() {
    totalAmtBid = 0.00;
    totalPercBid = 0.00;
    offerBids.forEach((m) {
      totalAmtBid += m.amount;
      totalPercBid += m.reservePercent;
    });

    totalToGo = offer.offerAmount - totalAmtBid;
    print(
        '_InvoiceBidderState._calculate --- offer.offerAmount:  ${offer.offerAmount} totalAmtBid: $totalAmtBid totalToGo: $totalToGo ');
    if (offer.offerAmount == totalAmtBid) {
      showFullyBid = true;
    }
    setState(() {});
  }

  bool showFullyBid = false;
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(160.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Bids for Offer: ',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                        child: Text(
                          offerBids == null ? '0' : '${offerBids.length}',
                          style: Styles.blackBoldLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              ' Reserved:',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 10.0),
                              child: Text(
                                totalPercBid == null
                                    ? '0 %'
                                    : '$totalPercBid %',
                                style: Styles.blackBoldLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text(
                      'Total Amount Bid: ',
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      totalAmtBid == null
                          ? '0.00'
                          : '${getFormattedAmount('$totalAmtBid', context)}',
                      style: Styles.whiteBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text('Amount To Go: ', style: Styles.blackBoldSmall),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      totalToGo == null
                          ? '0.00'
                          : '${getFormattedAmount('$totalToGo', context)}',
                      style: Styles.blackBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            _showBusyIndicator == false
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(
                            loadText,
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Container(
                          height: 16.0,
                          width: 16.0,
                          child: CircularProgressIndicator(),
                        ),
                      ],
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

  String loadText;
  Widget _getBody() {
    return Container(
      color: Colors.brown.shade100,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
            child: OfferCard(
              offer: offer,
              elevation: 2.0,
            ),
          ),
          showFullyBid == true ? _buildFullyBid() : _buildActions(),
        ],
      ),
    );
  }

  Widget _buildFullyBid() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 24.0, left: 12.0, right: 12.0, top: 4.0),
      child: GestureDetector(
        onTap: _closeOffer,
        child: Card(
          elevation: 8.0,
          color: Colors.teal.shade400,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  'This offer is now fully bid. It is no longer possible to make a bid on this offer for anyone else.\n\nThanks!',
                  style: Styles.whiteSmall,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 0.0, left: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Invoice Due Diligence',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.pink,
                  ),
                  onPressed: _onSearch,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 10.0, top: 0.0, right: 10.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              DropdownButton<double>(
                items: items,
                elevation: 8,
                hint: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Select Percentage',
                    style: Styles.blackBoldMedium,
                  ),
                ),
                onChanged: _onChanged,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  percentage == null ? '0.0 %' : '$percentage %',
                  style: Styles.blackBoldLarge,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 0.0),
          child: Row(
            children: <Widget>[
              Text(
                'Bid Amount:',
                style: Styles.blackSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  amount == null
                      ? '0.00'
                      : getFormattedAmount('$amount', context),
                  style: Styles.tealBoldReallyLarge,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 80.0, right: 80.0, top: 20.0, bottom: 30.0),
          child: RaisedButton(
            onPressed: _showConfirmDialog,
            elevation: 8.0,
            color: Colors.indigo.shade300,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Make Invoice Bid',
                style: Styles.whiteSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Confirm Invoice Bid",
                style: Styles.blackBoldLarge,
              ),
              content: Container(
                height: 200.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                          'Do you want to make an Invoice Bid?\n\nThis will record your intention to purchase the Offer at the proportion you specified.'),
                    ),
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
                  padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
                  child: RaisedButton(
                    onPressed: _onSubmitBid,
                    elevation: 8.0,
                    color: Colors.teal.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Confirm Bid',
                        style: Styles.whiteSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  double percentage, amount;
  bool isBusy = false;

  List<DropdownMenuItem<double>> items = List();
  void _buildPercChoices() {
    items.clear();
    var maxPerc = 100.0 - totalPercBid;
    print('_InvoiceBidderState._buildPercChoices maxPerc: $maxPerc');
    double count = 0.0;
    double val = 0.0;
    if (maxPerc > 0) {
      for (var i = 0; i < 9; i++) {
        val += 0.1;
        var m = DropdownMenuItem<double>(
          value: double.parse(val.toStringAsFixed(1)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${val.toStringAsFixed(1)} %',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
        );
        items.add(m);
      }
    }

    while (maxPerc > 0) {
      maxPerc -= 1.0;
      count++;
      var m = DropdownMenuItem<double>(
        value: count,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$count %',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ],
        ),
      );
      items.add(m);
    }
  }

  void _onChanged(double value) {
    percentage = value;
    print('_InvoiceBidderState._onChanged: percentage: $percentage');

    setState(() {
      amount = (percentage / 100.00) * offer.offerAmount;
    });
    print('_InvoiceBidderState._onChanged, amount: $amount');
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';

  List<InvoiceBid> offerBids;
  void _onSubmitBid() async {
    Navigator.pop(context);
    if (isBusy) {
      print('_InvoiceBidderState._onSubmitBid submit is busy');
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Busy. Device already subnitting bid. Please wait',
          textColor: Styles.yellow,
          backgroundColor: Styles.black);
      return;
    }
    if (percentage == null) {
      print('_InvoiceBidderState._onSubmitBid submit is busy');
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select percentage of offer',
          textColor: Styles.yellow,
          backgroundColor: Styles.black);
      return;
    }

    setState(() {
      loadText = 'Submitting your bid ... please wait';
      _showBusyIndicator = true;
    });

    var t = 0.00;
    offerBids.forEach((m) {
      t += m.reservePercent;
    });
    print(
        '_OffersAndBidsState._showOfferDialog ------------ percentage bids on offer: $t %');

    ///check if offer is 100 % reserved
    if (t >= 100.0) {
      AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Offer has been filled. Cannot be bid on',
        listener: this,
        actionLabel: '',
      );
      _scaffoldKey.currentState.removeCurrentSnackBar();
      return;
    }

    ///check if bid goes over 100 %
    if ((t + percentage) > 100.0) {
      AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Cannot make bid. Percentage required is too much',
        listener: this,
        actionLabel: '',
      );
      return;
    }

    ///check if bid percentage is not more than remaining portion unreserved
    if (percentage > (100.0 - t)) {
      AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Cannot make bid. Percentage required is not availale',
        listener: this,
        actionLabel: '',
      );
      return;
    }
    //todo - check investor limits if profile exists
    //todo - check invoice limits if profile exists

    //todo - check investor account balance
    isBusy = true;
    prettyPrint(offer.toJson(),
        '_InvoiceBidderState._onMakeBid ...........everything checks out. Making a bid:');
    /*
    bid.investorDocRef = unit.profile.investorDocRef;
        bid.offerDocRef = unit.offer.documentReference;
     */
    var token = await _firebaseMessaging.getToken();
    InvoiceBid bid = InvoiceBid(
        user: NameSpace + 'User#' + user.userId,
        reservePercent: percentage,
        offer: offer.offerId,
        investor: investor.participantId,
        investorName: investor.name,
        amount: amount,
        discountPercent: offer.discountPercent,
        startTime: offer.startTime,
        endTime: offer.endTime,
        wallet: wallet.stellarPublicKey,
        isSettled: false,
        supplierName: offer.supplierName,
        customerName: offer.customerName,
        customer: offer.customer,
        supplier: offer.supplier);

    try {
      await DataAPI3.makeInvoiceBid(bid);

      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Bid successful\nRefreshing bid data ...',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'OK',
          listener: this,
          icon: Icons.done_all,
          action: 0);
      print(
          '_InvoiceBidderState._onSubmitBid offerBids before: : ${offerBids.length}');
      offerBids.add(bid);
      _calculateTotal();
      _buildPercChoices();
      print(
          '_InvoiceBidderState._onSubmitBid offerBids after: : ${offerBids.length}');
      setState(() {
        _showBusyIndicator = false;
      });
      await investorModelBloc.refreshDashboard();
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Bid failed',
          listener: this,
          actionLabel: 'CLOSE');
    }
  }

  static const SUCCESS = 1;
  @override
  onActionPressed(int action) {
    //Navigator.pop(context);
    Navigator.pop(context, true);
  }

  void _onSearch() {
    print('_InvoiceBidderState._onSearch ================= ');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new InvoiceDueDiligence(offer)),
    );
  }

  @override
  onOfferMessage(Offer offer) {
    // TODO: implement onInvalidTrade
  }

  @override
  onInvoiceBidMessage(invoiceBid) {
    print(
        '_InvoiceBidderState.onInvoiceBidMessage -- bid from investor: ${invoiceBid.investorName}');
    if (invoiceBid.investor ==
        NameSpace + 'Investor#${investor.participantId}') {
      print(
          '_InvoiceBidderState.onInvoiceBidMessage IGNORE - this is our own bid');
    } else {
      _getExistingBids();
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Bid happened',
          textColor: Styles.white,
          backgroundColor: Colors.teal.shade900);
    }
  }

  @override
  onHeartbeat(Map map) {
    // TODO: implement onHeartbeat
  }

  void _closeOffer() {
    print('_InvoiceBidderState._closeOffer ############ CLOSE OFFER ......');
  }
}
