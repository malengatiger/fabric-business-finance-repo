import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/customer_bloc.dart';
import 'package:customer/ui/settle_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SettlementList extends StatefulWidget {
  @override
  _SettlementListState createState() => _SettlementListState();
}

class _SettlementListState extends State<SettlementList>
    implements SnackBarListener, PagerControlListener {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  List<InvestorInvoiceSettlement> currentPage;
  ScrollController controller1 = ScrollController();
  CustomerApplicationModel appModel;
  int _pageNumber = 1;

  @override
  initState() {
    super.initState();
    appModel = customerBloc.appModel;
    setBasePager();
  }

  void fix() async {
    Firestore fs = Firestore.instance;
    int count = 0;
    var start = DateTime.now();
    print('\n\n_SettlementListState.fix ###################### start .... ');
    var qs = await fs
        .collection('settlements')
        .orderBy('date', descending: true)
        .getDocuments();
    print(
        '_SettlementListState.fix settlements found: ${qs.documents.length} ');
    for (var doc in qs.documents) {
      var stlmnt = InvestorInvoiceSettlement.fromJson(doc.data);
      var qs2 = await fs
          .collection('offers')
          .where('offerId', isEqualTo: stlmnt.offer)
          .getDocuments();
      for (var doc2 in qs2.documents) {
        var offer = Offer.fromJson(doc2.data);
        stlmnt.customer = offer.customer;
        stlmnt.supplier = offer.supplier;
        stlmnt.supplierName = offer.supplierName;
        stlmnt.customerName = offer.customerName;

        doc.reference.setData(stlmnt.toJson());
        count++;
        print(
            '_SettlementListState.fix -- #$count - settlement updated ${stlmnt.investorName} to ${stlmnt.supplierName} - ${stlmnt.amount}');
      }
    }
    var end = DateTime.now();
    print(
        '_SettlementListState.fix ######### cpmplete. elapsed: ${end.difference(start).inSeconds} seconds');
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() async {
    if (appModel == null) return;
    print(
        '_SettlementListState.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (appModel.settlements == null || appModel.settlements.isEmpty) {
      await customerBloc.refreshModel();
      setState(() {});
      return;
    }
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.settlements,
        pageLimit: appModel.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    _pageNumber = 1;
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
    setState(() {});
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
    if (appModel == null) return 0.00;
    var t = 0.0;
    appModel.settlements.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  @override
  onNextPageRequired() {
    print(
        '_InvoicesOnOfferState.onNextPageRequired ...........current _pageNumber: $_pageNumber............');
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

    print(
        '_SettlementListState.onNextPageRequired --- setting state with new current page? why no rebuild????');
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
          scaffoldKey: _key,
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

//end of paging constructs
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: new Size.fromHeight(200.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          appModel == null
              ? Container()
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
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
                          bottom: 20.0, left: 12.0, right: 12.0),
                      child: PagerControl(
                        itemName: 'Settlements',
                        pageLimit: appModel.pageLimit,
                        elevation: 8.0,
                        items: appModel.settlements.length,
                        listener: this,
                        color: Colors.purple.shade50,
                        pageNumber: _pageNumber,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _getBody() {
    if (currentPage == null || currentPage.isEmpty) {
      return Center(
        child: Text(
          'Loading settlement data',
          style: Styles.blackBoldLarge,
        ),
      );
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.minScrollExtent,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: controller1,
        itemBuilder: (BuildContext context, int index) {
          return new Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0),
            child: GestureDetector(
              onTap: () {
                _onSettlementTapped(currentPage.elementAt(index));
              },
              child:
                  new SettlementCard(settlement: currentPage.elementAt(index)),
            ),
          );
        });
  }

  void _onRefresh() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _key,
        message: 'Loading investor settlements ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    await customerBloc.refreshSettlements();
    setBasePager();
    _key.currentState.removeCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    print('_SettlementListState.build ....... re-building widget ....');
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Investor Settlements'),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            onPressed: _onRefresh,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: _getBody(),
    );
  }

  void _onSettlementTapped(InvestorInvoiceSettlement settlement) {
    prettyPrint(
        settlement.toJson(), '_SettlementListState._onSettlementTapped');
    _checkSettlement(settlement);
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }

  Invoice invoice;
  void _checkSettlement(InvestorInvoiceSettlement settlement) async {
    try {
      var bid =
          await ListAPI.getInvoiceBidById(invoiceBidId: settlement.invoiceBid);
      offerBag = await ListAPI.getOfferById(bid.offer);
      invoice = await ListAPI.getCustomerInvoiceById(
          invoiceId: offerBag.offer.invoice);

      prettyPrint(bid.toJson(), '+++++++++++++++ Bid:');
      offerBag.doPrint();
      prettyPrint(invoice.toJson(),
          '########### Invoice to be settled by CUSTOMER!!!:');
      _showInvoiceSettlementDialog();
    } catch (e) {
      print(e);
    }
  }

  void _showInvoiceSettlementDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Settlement",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    new Text("Do you want to settle this Invoice?\n\ "),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Invoice Number:',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${invoice.invoiceNumber}',
                              style: Styles.blackBoldMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Invoice Amount:',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${getFormattedAmount('${invoice.totalAmount}', context)}',
                              style: Styles.tealBoldMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'NO',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 16.0, bottom: 10.0),
                  child: RaisedButton(
                    elevation: 4.0,
                    onPressed: _startSettlement,
                    color: Colors.teal,
                    child: Text(
                      'YES',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  OfferBag offerBag;
  void _startSettlement() {
    print('_SettlementListState._startSettlement .....................');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => SettleInvoice(
                invoice: invoice,
                offerBag: offerBag,
              )),
    );
  }
}

class SettlementCard extends StatelessWidget {
  final InvestorInvoiceSettlement settlement;
  final double elevation;
  final Color color;

  SettlementCard({@required this.settlement, this.elevation, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 2.0 : elevation,
      color: color == null ? Colors.white : color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                    width: 30.0,
                    child: Text(
                      '${settlement.itemNumber}',
                      style: Styles.purpleBoldSmall,
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    getFormattedDateShortWithTime(settlement.date, context),
                    style: Styles.blueSmall,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 80.0,
                    child: Text(
                      'Supplier',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Text(
                    settlement.supplierName,
                    style: Styles.blackBoldSmall,
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 80.0,
                  child: Text(
                    'Investor',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  settlement.investorName == null
                      ? 'Not available'
                      : settlement.investorName,
                  style: Styles.blackBoldSmall,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
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
                    getFormattedAmount('${settlement.amount}', context),
                    style: Styles.tealBoldMedium,
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
