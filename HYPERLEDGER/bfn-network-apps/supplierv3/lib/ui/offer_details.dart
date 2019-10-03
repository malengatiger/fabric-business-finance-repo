import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/common.dart';
import 'package:supplierv3/supplier_bloc.dart';

class OfferDetails extends StatefulWidget {
  final Offer mOffer;

  OfferDetails(this.mOffer);

  @override
  _OfferDetailsState createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails>
    implements DiscountListener, SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<InvoiceBid> bids = List();
  OfferBag bag;
  Offer offer;
  SupplierApplicationModel appModel;
  @override
  void initState() {
    super.initState();
    appModel = supplierBloc.appModel;
    _getBids();
  }

  _getBids() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading bids ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    bag = await ListAPI.getOfferWithBids(widget.mOffer.offerId);
    bids = bag.invoiceBids;
    offer = bag.offer;
    _scaffoldKey.currentState.removeCurrentSnackBar();

    setState(() {});
  }

  Widget _getBottom() {
    const width = 70.0;
    return PreferredSize(
      preferredSize: Size.fromHeight(260.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: width,
                  child: Text(
                    'Offer Amount',
                    style: Styles.whiteSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    offer == null
                        ? '0.00'
                        : getFormattedAmount('${offer.offerAmount}', context),
                    style: Styles.whiteBoldLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 0.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: width,
                    child: Text(
                      'Offer Date',
                      style: Styles.whiteSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      offer == null
                          ? ''
                          : '${getFormattedDateLongWithTime(offer.date, context)}',
                      style: Styles.whiteSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: width,
                    child: Text(
                      'Invoice Discount',
                      style: Styles.whiteSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      offer == null ? '' : '${offer.discountPercent} %',
                      style: Styles.whiteBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Invoice Bids',
                    style: Styles.whiteSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                    child: Text(
                      bids == null ? '0' : '${bids.length}',
                      style: Styles.whiteBoldLarge,
                    ),
                  )
                ],
              ),
            ),
            _getHeader(),
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
      ),
    );
  }

  Widget _getHeader() {
    var t = 0.00;
    var p = 0.00;
    if (bids != null) {
      bids.forEach((m) {
        t += m.amount;
        p += m.reservePercent;
      });
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 120.0,
                child: Text(
                  'Total Amount Bid',
                  style: Styles.whiteSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  getFormattedAmount('$t', context),
                  style: Styles.blackBoldMedium,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 12.0, right: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 140.0,
                child: Text(
                  'Total Percentage Bid',
                  style: Styles.whiteSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '$p %',
                  style: Styles.blackBoldMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _cancelOffer() async {
    print('_OfferDetailsState._cancelOffer .........................');
    if (offer.isCancelled == true) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is already cancelled',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Cancelling Offer ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    try {
      offer.isCancelled = true;

      var mOffer = await DataAPI3.updateOffer(offer);
      prettyPrint(mOffer.toJson(), '############ Cancelled Offer:');
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Offer cancelled',
          textColor: Styles.white,
          backgroundColor: Theme.of(context).primaryColor,
          actionLabel: 'Exit',
          listener: this,
          icon: Icons.done,
          action: 3);

      await supplierBloc.refreshModel();
      setState(() {});
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer cancellation failed',
          listener: this,
          actionLabel: 'Close');
    }
  }

  Future _updateOffer() async {
    print('_OfferDetailsState._updateOffer  ..... $discountPercentage %');
    if (discountPercentage == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select new discount percentage',
          listener: this,
          actionLabel: 'OK');
      return;
    }

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Updating Offer ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    offer.discountPercent = discountPercentage;
    offer.offerAmount = getOfferAmount();
    var end = DateTime.parse(offer.endTime);
    var newTime = end.add(Duration(days: 14));
    offer.endTime = getUTC(newTime);

    try {
      var res = await DataAPI3.updateOffer(offer);
      prettyPrint(res.toJson(),
          '########### UPDATED offer, discountPercent : $discountPercentage');

      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Offer updated',
          textColor: Styles.white,
          backgroundColor: Theme.of(context).primaryColor,
          actionLabel: 'Exit',
          listener: this,
          icon: Icons.done,
          action: 3);

      await supplierBloc.refreshModel();
      setState(() {});
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Discount percentage update failed',
          listener: this,
          actionLabel: 'Close');
    }
  }

  double getOfferAmount() {
    var offerAmt = (offer.invoiceAmount * (100.0 - discountPercentage)) / 100.0;
    return offerAmt;
  }

  double discountPercentage;
  @override
  onDiscount(String discount) {
    print('_OfferDetailsState.onDiscount new percentage selected: $discount');
    discountPercentage = double.parse(discount);
    if (discountPercentage == offer.discountPercent) {
      return;
    } else {
      setState(() {
        offer.discountPercent = discountPercentage;
        offer.offerAmount = getOfferAmount();
      });
    }
  }

  Widget _noBidsView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No bids on the blockchain',
            style: Styles.greyLabelMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      getDiscountDropDown(this),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          discountPercentage == null
                              ? '${offer.discountPercent.toStringAsFixed(2)}'
                              : '${discountPercentage.toStringAsFixed(2)}',
                          style: Styles.blackBoldLarge,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Offer Amount',
                        style: Styles.greyLabelSmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          getFormattedAmount('${offer.offerAmount}', context),
                          style: Styles.tealBoldLarge,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: _cancelOffer,
                        child: Text(
                          'Cancel Offer',
                          style: Styles.blueSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, top: 32.0, bottom: 20.0),
                        child: RaisedButton(
                          elevation: 6.0,
                          onPressed: _updateOffer,
                          color: Colors.pink,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Update Offer',
                              style: Styles.whiteSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    offer = widget.mOffer;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Offer Details'),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            onPressed: _getBids,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: bids.isEmpty
          ? _noBidsView()
          : ListView.builder(
              itemCount: bids == null ? 0 : bids.length,
              itemBuilder: (BuildContext context, int index) {
                return new InkWell(
                  onTap: () {
                    _acceptBid(bids.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, left: 20.0, right: 20.0),
                    child: BidCard(
                      invoiceBid: bids.elementAt(index),
                    ),
                  ),
                );
              }),
    );
  }

  void _acceptBid(InvoiceBid bid) {
    print('_OfferDetailsState._acceptBid ${bid.toJson()}');
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    // TODO: implement onInvoiceBidMessage
    bids.insert(0, invoiceBid);
    setState(() {});
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Styles.white,
        backgroundColor: Styles.teal);
  }

  @override
  onActionPressed(int action) {
    switch (action) {
      case 3:
        Navigator.pop(context);
        break;
    }
    return null;
  }
}

class BidCard extends StatelessWidget {
  final InvoiceBid invoiceBid;

  BidCard({this.invoiceBid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  getFormattedDateLong('${invoiceBid.date}', context),
                  style: Styles.blackBoldSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    getFormattedDateHour('${invoiceBid.date}'),
                    style: Styles.purpleBoldSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Investor',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${invoiceBid.investorName}',
                      style: Styles.blackBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  child: Text(
                    'Reserved',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${invoiceBid.reservePercent} %',
                    style: Styles.blackBoldMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Amount',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      getFormattedAmount('${invoiceBid.amount}', context),
                      style: Styles.pinkBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Trade Type',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  _getType(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getType() {
    if (invoiceBid.autoTradeOrder != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Auto Trade',
          style: Styles.blueBoldSmall,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Manual Trade',
          style: Styles.blackBoldSmall,
        ),
      );
    }
  }
}
