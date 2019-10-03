import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/offerCancellation.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/make_offer.dart';

class InvoicesOnOffer extends StatefulWidget {
  final SupplierApplicationModel model;

  InvoicesOnOffer({this.model});

  @override
  _InvoicesOnOfferState createState() => _InvoicesOnOfferState();
}

class _InvoicesOnOfferState extends State<InvoicesOnOffer>
    implements PagerControlListener, SnackBarListener {
  List<Invoice> currentPage;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int currentStartKey;
  SupplierApplicationModel appModel;

  @override
  void initState() {
    super.initState();
  }

  Future _goMakeOffer(Invoice invoice) async {
    //check for acceptance
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    var acceptance =
        await ListAPI.getInvoiceAcceptanceByInvoice(invoice.invoiceId);

    if (acceptance == null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'The invoice has not been accepted yet',
          textColor: Styles.yellow,
          backgroundColor: Styles.black);
      return;
    }

    var offX = await ListAPI.getOfferByInvoice(invoice.invoiceId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (offX == null) {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoice)),
      );
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already exists',
          listener: this,
          actionLabel: 'Close');
    }
  }

  void _viewOffer(Invoice invoice) async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Getting Offer details ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    var bag = await ListAPI.getOfferByInvoice(invoice.invoiceId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    prettyPrint(bag.offer.toJson(), '_InvoiceListState._viewOffer .......');
    var now = DateTime.now();
    var start = DateTime.parse(bag.offer.startTime);
    var end = DateTime.parse(bag.offer.endTime);
    print(
        'ListAPI.getInvoicesOnOffer start: ${start.toIso8601String()} end: ${end.toIso8601String()} now: ${now.toIso8601String()}');
    if (now.isAfter(start) && now.isBefore(end)) {
      print(
          '_InvoiceListState._viewOffer ======= this is valid. between  start and end times');
      _showCancelDialog(bag.offer);
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer has expired or settled',
          listener: this,
          actionLabel: 'CLOSE');
    }
  }

  Offer offer;
  void _showCancelDialog(Offer offer) {
    this.offer = offer;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Offer Cancellattion",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 200.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'This invoice has been offered to the BFN network.\n\nDo you want to cancel this offer?: \n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('Offer Amount'),
                        ),
                        Text(
                          offer.offerAmount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${offer.offerAmount}', context),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text('Offer Date'),
                          ),
                          Text(
                            offer.startTime == null
                                ? ''
                                : getFormattedDate(offer.startTime),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('NO')),
                FlatButton(
                  onPressed: _cancelOffer,
                  child: Text('YES'),
                )
              ],
            ));
  }

  void _cancelOffer() async {
    print('_InvoiceListState._cancelOffer ..........');
    Navigator.pop(context);

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking offer ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    var m = await ListAPI.getOfferByOfferId(offer.offerId);

    if (m.invoiceBids != null && m.invoiceBids.isNotEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already has bids. Cannot be cancelled',
          listener: this,
          actionLabel: 'CLOSE');
      _scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }

    var cancellation =
        OfferCancellation(offer: offer.offerId, user: appModel.user.userId);

    var result = await DataAPI3.cancelOffer(cancellation);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Cancel failed',
          listener: this,
          actionLabel: 'CLOSE');
    } else {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer cancelled',
          textColor: Colors.yellow,
          backgroundColor: Colors.black);
    }
  }

  bool isRefreshModel = false;
  int _pageNumber = 1;
  BasePager basePager;
  void setBasePager() {
    if (appModel == null) return;
    print(
        '_InvoicesOnOfferState.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.invoices,
        pageLimit: appModel.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
  }

  Future _refresh() async {
    setState(() {
      isRefreshModel = true;
    });
  }

  double _getPageValue() {
    if (currentPage == null) return 0.00;
    var t = 0.00;
    currentPage.forEach((inv) {
      t += inv.amount;
    });
    return t;
  }

  double _getTotalValue() {
    if (appModel == null) return 0.00;
    var t = 0.00;
    appModel.invoices.forEach((inv) {
      t += inv.amount;
    });
    return t;
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(220.0),
      child: appModel == null
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
                    totalValueStyle: Styles.brownBoldMedium,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: PagerControl(
                    itemName: 'Invoices',
                    pageLimit: appModel.pageLimit,
                    elevation: 16.0,
                    items: appModel.invoices.length,
                    listener: this,
                    color: Colors.amber.shade50,
                    pageNumber: _pageNumber,
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

  _onInvoiceTapped(Invoice invoice) {
    if (invoice.isOnOffer) {
      _viewOffer(invoice);
    } else {
      _goMakeOffer(invoice);
    }
  }

  ScrollController scrollController = ScrollController();
  Widget _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });

    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: () {
                _onInvoiceTapped(currentPage.elementAt(index));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                child: InvoiceOnOfferCard(
                  invoice: currentPage.elementAt(index),
                  context: context,
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (appModel == null) {
      print(
          '\n\n_InvoicesOnOfferState.build --------------------- set appModel');
      appModel = widget.model;
      setBasePager();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoices'),
//        backgroundColor: Colors.brown.shade200,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
        bottom: _getBottom(),
      ),
      body: _getListView(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

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
          backgroundColor: Styles.brown);
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
}

class InvoiceOnOfferCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  final double elevation;

  InvoiceOnOfferCard({this.invoice, this.context, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: Card(
        elevation: elevation == null ? 2.0 : elevation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${invoice.itemNumber}',
                      style: Styles.blackBoldSmall,
                    ),
                  ),
                  Text(
                    getFormattedDateLongWithTime(invoice.date, context),
                    style: Styles.blackSmall,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      invoice.customerName,
                      style: Styles.blackBoldMedium,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60.0,
                      child: Text(
                        'Amount',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.amount == null ? '0.00' : _getFormattedAmt(),
                        style: Styles.blackSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60.0,
                      child: Text(
                        'VAT',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.valueAddedTax == null
                            ? '0.00'
                            : _getFormattedAmt(),
                        style: Styles.blackSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60.0,
                    child: Text(
                      'Invoice',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      invoice.invoiceNumber == null
                          ? ''
                          : invoice.invoiceNumber,
                      style: Styles.blackSmall,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60.0,
                      child: Text(
                        'Total',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.totalAmount == null
                            ? '0.00'
                            : _getFormattedAmt(),
                        style: Styles.tealBoldMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedAmt() {
    return getFormattedAmount('${invoice.totalAmount}', context);
  }
}

class AppBarBottom extends StatelessWidget {
  final PagerControlListener listener;
  final double pageValue, totalValue;
  final int pageLimit, pageNumber, items;

  AppBarBottom(
      {@required this.listener,
      @required this.pageValue,
      @required this.totalValue,
      @required this.pageLimit,
      @required this.items,
      @required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: PagingTotalsView(
              pageValue: pageValue,
              totalValue: totalValue,
              labelStyle: Styles.blackSmall,
              pageValueStyle: Styles.blackBoldLarge,
              totalValueStyle: Styles.brownBoldMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 20.0),
            child: PagerControl(
              itemName: 'Invoices',
              pageLimit: pageLimit,
              elevation: 16.0,
              items: items,
              listener: listener,
              color: Colors.amber.shade50,
              pageNumber: pageNumber,
            ),
          ),
        ],
      ),
    );
  }
}
