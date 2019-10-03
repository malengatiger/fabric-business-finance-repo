import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/investor_model_bloc.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:investor/bloc/bloc.dart';
import 'package:investor/ui/settle_invoice_bid.dart';

class UnsettledBids extends StatefulWidget {
  @override
  _UnsettledBidsState createState() => _UnsettledBidsState();
}

class _UnsettledBidsState extends State<UnsettledBids>
    implements PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Investor investor;
  List<InvoiceBid> currentPage = List();
  InvestorAppModel appModel;
  bool isBusy, forceRefresh = false;
  FirebaseMessaging _fm = FirebaseMessaging();
  double totalBidAmount = 0.00;
  double avgDiscount = 0.0, possibleROI = 0.0;
  FCM _fcm = FCM();
  @override
  void initState() {
    super.initState();
    _getCache();
    appModel = investorModelBloc.appModel;
  }

  _getCache() async {
    investor = await SharedPrefs.getInvestor();
    _setBasePager();
    setState(() {});
  }

  double _getHeight() {
    if (appModel.unsettledInvoiceBids == null) return 220.0;
    if (appModel.unsettledInvoiceBids.length < 2) {
      return 220.0;
    } else {
      return 260.0;
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(_getHeight()),
      child: appModel.unsettledInvoiceBids == null
          ? Container()
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: PagingTotalsView(
                    pageValue: _getPageValue(),
                    totalValue: _getTotalValue(),
                    labelStyle: Styles.blackSmall,
                    pageValueStyle: Styles.blackBoldLarge,
                    totalValueStyle: Styles.brownBoldMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 12.0),
                  child: PagerControl(
                    itemName: 'Invoice Bids to Settle',
                    pageLimit: appModel.pageLimit,
                    elevation: 16.0,
                    items: appModel.unsettledInvoiceBids.length,
                    listener: this,
                    color: Colors.purple.shade50,
                    pageNumber: _pageNumber,
                  ),
                ),
                appModel.unsettledInvoiceBids.length < 2
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 8.0, bottom: 12.0),
                        child: _getButton(),
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
    );
  }

  Widget _getButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RaisedButton(
          onPressed: _startSettleAll,
          elevation: 4.0,
          color: Colors.pink,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Settle All On Page',
              style: Styles.whiteSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48.0),
          child: InkWell(
            onTap: _sort,
            child: Row(
              children: <Widget>[
                Text('Sort Page'),
                IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: _sort,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ScrollController scrollController = ScrollController();
  Widget _getBody() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
    if (currentPage == null || currentPage.isEmpty) {
      return ListView(
        controller: scrollController,
      );
    }
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
            onTap: () {
              _checkBid(currentPage.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: InvoiceBidCard(
                  bid: currentPage.elementAt(index),
                  elevation: 1.0,
                  showItemNumber: true,
                ),
              ),
            ),
          );
        });
  }

  void _showBidDialog(InvoiceBid invoiceBid) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Invoice Bid Settlement",
                  style: Styles.blackBoldMedium),
              content: Container(
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Do you want to settle this Invoice Bid?',
                        style: Styles.blackMedium,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Amount:',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: Text(
                            getFormattedAmount('${invoiceBid.amount}', context),
                            style: Styles.tealBoldLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('NO'),
                ),
                RaisedButton(
                  elevation: 4.0,
                  onPressed: () {
                    _startSettlement(invoiceBid);
                  },
                  child: Text(
                    'YES',
                    style: Styles.whiteSmall,
                  ),
                ),
              ],
            ));
  }

  void _checkBid(InvoiceBid bid) async {
    print('_UnsettledBidsState._checkBid ...............');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking offer for this bid ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    bool isFound = false;
    var unsettledBids = appModel.unsettledInvoiceBids;
    unsettledBids.forEach((b) {
      if (b.invoiceBidId == bid.invoiceBidId) {
        isFound = true;
      }
    });
    _scaffoldKey.currentState.removeCurrentSnackBar();
    if (isFound) {
      _showBidDialog(bid);
    } else {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'This bid may already be settled',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }
  }

  _startSettlement(InvoiceBid invoiceBid) async {
    prettyPrint(
        invoiceBid.toJson(), "Start settlement for this bid. check offer");
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => SettleInvoiceBid(
              invoiceBid: invoiceBid,
            ),
      ),
    );
  }

  void _startSettleAll() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => SettleInvoiceBid(
              invoiceBids: currentPage,
            ),
      ),
    );
  }

  bool isFromSettlement = false,
      isOpenMultiple = false,
      pagerShouldRefresh = false,
      refreshBidsInModel = false;
  void _onRefreshPressed() async {
    print(
        '\n_UnsettledBidsState._onRefreshPressed should refresh, has it? ...... pagerShouldRefresh = $pagerShouldRefresh}');

    setState(() {
      refreshBidsInModel = true;
    });
  }

  int buildCount = 0;
  double _opacity2 = 1.0;
  @override
  Widget build(BuildContext context) {
    if (isOpenMultiple) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Settle ${currentPage.length} Bids'),
          leading: IconButton(
              icon: Icon(
                Icons.apps,
                color: Colors.white,
              ),
              onPressed: null),
          bottom: _getBottom2(),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.help,
                  color: Colors.white,
                ),
                onPressed: null),
          ],
        ),
        body: _getBody2(),
        backgroundColor: Colors.brown.shade100,
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Offer Settlement',
          style: Styles.whiteBoldMedium,
        ),
        elevation: 4.0,
        bottom: _getBottom(),
        backgroundColor: Colors.teal.shade400,
        actions: <Widget>[
          IconButton(
            onPressed: _onRefreshPressed,
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: _getBody(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  String text =
      'The totals below represent the total amount of invoice bids made by you or by the BFN Network. A single payment will be made for all outstanding bids.';
  Widget _getBottom2() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Consolidated Invoice Bids',
                  style: Styles.whiteBoldMedium,
                ),
                Opacity(
                  opacity: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Container(
                      height: 16.0,
                      width: 16.0,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<String> messages = List();
  Widget _getBody2() {
    var tiles = List<ListTile>();
    tiles.clear();
    messages.forEach((m) {
      var tile = ListTile(
        leading: Icon(
          Icons.apps,
          color: getRandomColor(),
        ),
        title: Text(
          '${m}',
          style: Styles.blackBoldSmall,
        ),
      );
      tiles.add(tile);
    });
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Payment',
                          style: Styles.blackBoldLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            child: Container(
                                child: Text(
                          text,
                          style: Styles.blackBoldSmall,
                          overflow: TextOverflow.clip,
                        )))
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 120.0,
                        child: Text(
                          'Total Bids:',
                          style: Styles.greyLabelSmall,
                        ),
                      ),
                      Text(
                        currentPage == null
                            ? ''
                            : '${getFormattedNumber(currentPage.length, context)}',
                        style: Styles.blackBoldMedium,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 120.0,
                          child: Text(
                            'Avg Discount:',
                            style: Styles.greyLabelSmall,
                          ),
                        ),
                        Text(
                          avgDiscount == null
                              ? '0.0%'
                              : '${avgDiscount.toStringAsFixed(2)} %',
                          style: Styles.purpleBoldMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 120.0,
                          child: Text(
                            'Possible ROI:',
                            style: Styles.greyLabelSmall,
                          ),
                        ),
                        Text(
                          possibleROI == null
                              ? '0.0%'
                              : '${getFormattedAmount('$possibleROI', context)}',
                          style: Styles.blackBoldMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 80.0,
                          child: Text(
                            'Amount:',
                            style: Styles.greyLabelSmall,
                          ),
                        ),
                        Text(
                          '${getFormattedAmount('$totalBidAmount', context)}',
                          style: Styles.tealBoldLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Close',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: _opacity2,
                          child: RaisedButton(
                            elevation: 8.0,
                            color: Colors.pink,
                            onPressed: _confirmDialog,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  top: 12.0,
                                  bottom: 12.0),
                              child: Text(
                                'Settle ${currentPage.length} Bids',
                                style: Styles.whiteSmall,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: tiles,
          ),
        ],
      ),
    );
  }

  void _confirmDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Bid Settlement",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 80.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Do you want to settle all these ${currentPage.length} Invoice Bids?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Amount:',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: Text(
                            getFormattedAmount('$totalBidAmount', context),
                            style: Styles.tealBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('NO'),
                ),
                RaisedButton(
                  elevation: 6.0,
                  onPressed: () {
                    Navigator.pop(context);
                    _startMultiPayments();
                  },
                  child: Text(
                    'YES',
                    style: Styles.whiteSmall,
                  ),
                ),
              ],
            ));
  }

  double _opacity = 0.0;
  //paging constructs
  BasePager basePager;
  void _setBasePager() {
    if (appModel == null) return;
    print(
        '\n\n_PurchaseOrderList.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.unsettledInvoiceBids,
        pageLimit: appModel.pageLimit,
      );
    }

    if (currentPage == null)
      currentPage = List();
    else
      currentPage.clear();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
  }

  double _getPageValue() {
    if (currentPage == null) return 0.00;
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  double _getTotalValue() {
    if (appModel == null || appModel.unsettledInvoiceBids == null) return 0.00;
    var t = 0.0;
    appModel.unsettledInvoiceBids.forEach((po) {
      t += po.amount;
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
    print('_UnsettledBidsState.onPageLimit : $pageLimit');
    if (pageLimit == appModel.pageLimit) {
      return null;
    }
    await appModel.updatePageLimit(pageLimit);
    _pageNumber = 1;
    basePager = BasePager(
      items: appModel.unsettledInvoiceBids,
      pageLimit: pageLimit,
    );
    currentPage.clear();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
    setState(() {});
    basePager.doPrint();
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

  int sortToggle = 0;
  void _sort() {
    print('_UnsettledBidsState._sort ------- sorting, toggle: $sortToggle');
    if (sortToggle == 0) {
      currentPage.sort((a, b) => b.amount.compareTo(a.amount));
      sortToggle = 1;
      setState(() {});
      return;
    }
    if (sortToggle == 1) {
      currentPage.sort((a, b) => a.amount.compareTo(b.amount));
      sortToggle = 2;
      setState(() {});
      return;
    }
    if (sortToggle == 2) {
      currentPage.sort((a, b) => a.itemNumber.compareTo(b.itemNumber));
      sortToggle = 0;
      setState(() {});
    }
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    prettyPrint(invoiceBid.toJson(), '####### invoiceBid arrived');
    return null;
  }

  void _startMultiPayments() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => SettleInvoiceBid(
              invoiceBids: currentPage,
            ),
      ),
    );
  }

  @override
  onPeachNotify(PeachNotification notification) {
    prettyPrint(notification.toJson(),
        '\n\n\n########### notification arrived safely!:');
    return null;
  }
}
