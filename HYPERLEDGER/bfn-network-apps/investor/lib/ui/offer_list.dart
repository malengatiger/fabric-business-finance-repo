import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/investor_model_bloc.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/offer_card.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:investor/bloc/bloc.dart';
import 'package:investor/ui/invoice_bidder.dart';

class OfferList extends StatefulWidget {
  static _OfferListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_OfferListState>());
  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList>
    with WidgetsBindingObserver
    implements PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  List<Offer> baseList;

  List<Offer> currentPage = List();
  List<Offer> closedOffers = List();

  Investor investor;
  Offer offer;
  int currentStartKey, previousStartKey;
  OpenOfferSummary summary = OpenOfferSummary();
  List<int> keys = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    appModel = investorModelBloc.appModel;
    _buildDaysDropDownItems();
    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
  }

  List<InvoiceBid> offerBids;
  _checkBid(Offer offer) async {
    this.offer = offer;
    if (offer.isOpen == false) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is already closed',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking bid ...please wait',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);

    offerBids = await ListAPI.getInvoiceBidsByOffer(offer.offerId);
    offerBids.forEach((bid) {
      prettyPrint(bid.toJson(), '####### bid for this offer already exist:');
    });
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (offerBids.isEmpty) {
      _showInvoiceBidDialog(offer);
    } else {
      print(
          '########### INVOICE BID(s) for investor/offer found.... ${offerBids.length}');
      var tot = 0.0;
      offerBids.forEach((bid) {
        tot += bid.amount;
      });
      if (tot == offer.offerAmount) {
        print('_OfferListState._checkBid. offer is already fully bid ....');
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Offer is already fully bid',
            textColor: Styles.white,
            backgroundColor: Styles.black);
      } else {
        _showMoreBidsDialog();
      }
    }
  }

  _showMoreBidsDialog() {
    if (!offer.isOpen) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is already closed',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Add more bids",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Text(
                'Do you want to add another bid for this offer?',
                style: Styles.blackBoldMedium,
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onInvoiceBidRequired,
                  child: Text('MAKE INVOICE BID'),
                ),
              ],
            ));
  }

  _showInvoiceBidDialog(Offer offer) {
    this.offer = offer;

    if (offer.isOpen == false) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is closed',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    prettyPrint(offer.toJson(),
        '\n\n######## offer selected for bidding, check isOpen');
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Bid Actions",
                style: Styles.blackBoldLarge,
              ),
              content: Container(
                height: 240.0,
                width: double.infinity,
                child: OfferListCard(
                  offer: offer,
                  color: Colors.grey.shade50,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text(
                    'No',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                RaisedButton(
                  elevation: 8.0,
                  onPressed: _onInvoiceBidRequired,
                  color: Colors.teal.shade600,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'MAKE INVOICE BID',
                      style: Styles.whiteSmall,
                    ),
                  ),
                ),
              ],
            ));
  }

  TextStyle white = TextStyle(color: Colors.black, fontSize: 16.0);

  List<DropdownMenuItem<int>> _buildDaysDropDownItems() {
    var item0 = DropdownMenuItem<int>(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '1 Day Under Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item0);
    var itema = DropdownMenuItem<int>(
      value: 3,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '3 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(itema);
    var item1 = DropdownMenuItem<int>(
      value: 7,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '7 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item1);
    var item2 = DropdownMenuItem<int>(
      value: 14,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.teal,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '14 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item2);

    var item3 = DropdownMenuItem<int>(
      value: 30,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.brown,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '30 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item3);
    var item4 = DropdownMenuItem<int>(
      value: 60,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '60 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item4);
    var item5 = DropdownMenuItem<int>(
      value: 90,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.deepOrange,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '90 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item5);

    var item6 = DropdownMenuItem<int>(
      value: 120,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '120 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item6);
    var item7 = DropdownMenuItem<int>(
      value: 365,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '365 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item7);

    return items;
  }

  InvestorAppModel appModel;
  int mCount = 0;
  @override
  Widget build(BuildContext context) {
    mCount++;
    if (mCount == 1) {
      setBasePager();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Open Offers',
          style: Styles.whiteBoldMedium,
        ),
        bottom: PreferredSize(
          child: _getBottom(),
          preferredSize: Size.fromHeight(220.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sort,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _getListView(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  Offer _getOffer(int index) {
    if (currentPage == null) {
      return null;
    }
    return currentPage.elementAt(index);
  }

  List<DropdownMenuItem<int>> items = List();
  int currentIndex = 0;
  DashboardData dashboardData;
  ScrollController scrollController = ScrollController();
  Widget _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            onTap: () {
              _checkBid(currentPage.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0),
              child: OfferCard(
                offer: _getOffer(index),
                number: index + 1,
                color: Colors.amber.shade50,
                elevation: 1.0,
              ),
            ),
          );
        });
  }

  Widget _getBottom() {
    return appModel == null
        ? Container()
        : Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: PagingTotalsView(
                  pageValue: _getPageValue(),
                  totalValue: _getTotalValue(),
                  labelStyle: Styles.blackSmall,
                  pageValueStyle: Styles.blackBoldLarge,
                  totalValueStyle: Styles.whiteBoldMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, bottom: 8.0, top: 2.0),
                child: PagerControl(
                  itemName: 'Open Offers',
                  pageLimit: appModel.pageLimit,
                  elevation: 16.0,
                  items: appModel.offers == null ? 0 : appModel.offers.length,
                  listener: this,
                  color: Colors.brown.shade50,
                  pageNumber: _pageNumber,
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
          );
  }

  String text = 'OPEN';

  void _onNoPressed() {
    Navigator.pop(context);
  }

  Future _onInvoiceBidRequired() async {
    prettyPrint(offer.toJson(),
        '\n\n_OfferListState._onYesPressed.... OFFER to bidder:');
    Navigator.pop(context);
    bool refresh = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new InvoiceBidder(
                offer: offer,
                existingBids: offerBids,
              )),
    );
    if (refresh == null) {
      return;
    }

    if (refresh) {
      _refresh();
    }
  }

  void _refresh() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data',
        textColor: Styles.white,
        backgroundColor: Styles.brown);
    await investorModelBloc.refreshDashboard();
    try {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    } catch (e) {}
    _getCached();
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() {
    if (appModel.offers == null) return;
    print(
        '_OfferList.setBasePager appModel.pageLimit: ${appModel.pageLimit} offers: ${appModel.offers.length}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.offers,
        pageLimit: appModel.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
  }

  double _getPageValue() {
    if (currentPage == null) return 0.00;
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.offerAmount;
    });
    return t;
  }

  double _getTotalValue() {
    if (appModel == null) return 0.00;
    if (appModel.offers == null) return 0.00;
    var t = 0.0;

    appModel.offers.forEach((po) {
      t += po.offerAmount;
    });
    return t;
  }

  int _pageNumber = 1;
  @override
  onNextPageRequired() {
    print('_InvoicesOnOfferState.onNextPageRequired');
    if (currentPage == null) {
      currentPage = List();
    } else {
      currentPage.clear();
    }
    var page = basePager.getNextPage();
    if (page == null) {
      return;
    }
    page.forEach((f) {
      currentPage.add(f);
    });

    setState(() {
      _pageNumber = basePager.pageNumber;
    });
  }

  @override
  onPageLimit(int pageLimit) async {
    print('_InvoicesOnOfferState.onPageLimit');
    await appModel.updatePageLimit(pageLimit);
    _pageNumber = 1;
    basePager.getNextPage();
    return null;
  }

  @override
  onPreviousPageRequired() {
    print('_InvoicesOnOfferState.onPreviousPageRequired');
    if (currentPage == null) {
      currentPage = List();
    }

    var page = basePager.getPreviousPage();
    if (page == null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No more. No mas.',
          textColor: Styles.white,
          backgroundColor: Theme.of(context).primaryColor);
      return;
    }
    currentPage.clear();
    page.forEach((f) {
      currentPage.add(f);
    });

    setState(() {
      _pageNumber = basePager.pageNumber;
    });
  }

  //end of paging constructs

  void setOffers(List<Findable> items) {
    currentPage.clear();
    items.forEach((f) {
      currentPage.add(f);
    });
    setState(() {});
  }

  bool toggle = false;
  void _sort() {
    if (toggle) {
      currentPage.sort((a, b) => a.offerAmount.compareTo(b.offerAmount));
    } else {
      currentPage.sort((a, b) => b.offerAmount.compareTo(a.offerAmount));
    }
    toggle = !toggle;
    setState(() {});
  }
}

class OfferListCard extends StatelessWidget {
  final Offer offer;
  final Color color;
  final double width = 60.0;

  OfferListCard({this.offer, this.color});

  @override
  Widget build(BuildContext context) {
    //print'OfferListCard.build');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "Supplier",
              style: Styles.greyLabelSmall,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Container(
                child: Text(
                    offer.supplierName == null
                        ? 'Unknown yet'
                        : offer.supplierName,
                    overflow: TextOverflow.clip,
                    style: Styles.blackBoldSmall),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            children: <Widget>[
              Text(
                "Customer",
                style: Styles.greyLabelSmall,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Container(
                child: Text(
                  offer.customerName == null
                      ? 'Unknown yet'
                      : offer.customerName,
                  style: Styles.blackBoldSmall,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 40.0),
          child: Row(
            children: <Widget>[
              Container(
                  width: 60.0,
                  child: Text(
                    'Start',
                    style: Styles.greyLabelSmall,
                  )),
              Text(
                  offer.startTime == null
                      ? 'Unknown yet'
                      : getFormattedDate(offer.startTime),
                  style: Styles.blackBoldSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: <Widget>[
              Container(
                  width: 60.0,
                  child: Text(
                    'End',
                    style: Styles.greyLabelSmall,
                  )),
              Text(
                  offer.endTime == null
                      ? 'Unknown yet'
                      : getFormattedDate(offer.endTime),
                  style: Styles.pinkBoldSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 20.0),
          child: Row(
            children: <Widget>[
              Container(
                  width: 60.0,
                  child: Text(
                    'Amount',
                    style: Styles.greyLabelSmall,
                  )),
              Text(
                offer.offerAmount == null
                    ? 'Unknown yet'
                    : getFormattedAmount('${offer.offerAmount}', context),
                style: Styles.tealBoldLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
