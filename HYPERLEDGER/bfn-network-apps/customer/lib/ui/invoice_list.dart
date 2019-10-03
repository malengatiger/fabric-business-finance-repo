import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:customer/customer_bloc.dart';
import 'package:customer/ui/invoice_settlement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList>
    implements SnackBarListener, PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Customer entity;
  List<Invoice> currentPage = List();
  Invoice invoice;
  User user;
  CustomerApplicationModel appModel;
  int pageLimit;

  @override
  initState() {
    super.initState();
    _getCached();
  }

  _getCached() async {
    entity = await SharedPrefs.getCustomer();
    user = await SharedPrefs.getUser();
    appModel = customerBloc.appModel;
    pageLimit = appModel.pageLimit;
    _setBasePager();
    setState(() {});
  }

  void _acceptInvoice() async {
    print('_InvoiceListState._acceptInvoice');

    Navigator.pop(context);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Accepting  invoice ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    var acceptance = new InvoiceAcceptance(
        supplierName: invoice.supplierName,
        customerName: entity.name,
        supplier: invoice.supplier,
        date: getUTCDate(),
        invoice: invoice.invoiceId,
        customer: entity.participantId,
        invoiceNumber: invoice.invoiceNumber,
        user: user.userId);

    try {
      await DataAPI3.acceptInvoice(acceptance);
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice accepted',
          textColor: Colors.lightBlue,
          backgroundColor: Colors.black);
      customerBloc.refreshModel();
    } catch (e) {
      showError();
    }
  }

  void showError() {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Acceptance FAILED',
        listener: this,
        actionLabel: 'Close');
  }

  void _settleInvoice() {
    prettyPrint(invoice.toJson(),
        '_InvoiceListState._settleInvoice  go to InvoiceSettlementPage');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new InvoiceSettlementPage(invoice)),
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0),
      child: appModel == null
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
                    pageLimit: pageLimit,
                    elevation: 16.0,
                    items: appModel.invoices.length,
                    listener: this,
                    color: Colors.purple.shade50,
                    pageNumber: _pageNumber,
                  ),
                ),
                StreamBuilder<String>(
                  stream: customerBloc.fcmStream,
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

  bool basePagerHasExecuted = false;
  @override
  Widget build(BuildContext context) {
    if (!basePagerHasExecuted) {
      _setBasePager();
      basePagerHasExecuted = true;
    }
    return StreamBuilder<CustomerApplicationModel>(
      stream: customerBloc.appModelStream,
      builder: (context, snapshot) {
        print('🍇  🍇  🍇 StreamBuilder build: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.active) {
          print('☘ ☘ ☘ refreshing invoice list via appModel... ☘ ☘ ☘');
          appModel = snapshot.data;
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              'Invoices',
              style: Styles.blackBoldMedium,
            ),
            backgroundColor: Colors.pink.shade200,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  customerBloc.refreshModel();
                },
              )
            ],
            bottom: _getBottom(),
          ),
          backgroundColor: Colors.brown.shade100,
          body: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: new Column(
              children: <Widget>[
                new Flexible(
                  child: _getListView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ScrollController controller1 = ScrollController();

  Widget _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: controller1,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            onTap: () {
              _showDialog(currentPage.elementAt(index));
            },
            child: InvoiceCard(
              invoice: currentPage.elementAt(index),
              context: context,
            ),
          );
        });
  }

  void _showDialog(Invoice invoice) {
    prettyPrint(invoice.toJson(), '_showDialog: invoice:');

    this.invoice = invoice;
    if (invoice.invoiceAcceptance.trim() == 'n/a') {
      showInvoiceAcceptanceDialog();
    } else {
      showInvoiceSettlementDialog();
    }
  }

  void showInvoiceSettlementDialog() {
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
                      padding: const EdgeInsets.only(top: 28.0),
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
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
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
                    onPressed: _settleInvoice,
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

  void showInvoiceAcceptanceDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Acceptance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    new Text("Do you want to accept this Invoice?\n\ "),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
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
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
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
                    onPressed: _acceptInvoice,
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

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);

    setState(() {});
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more. Have not.',
        textColor: Styles.white,
        backgroundColor: Colors.brown.shade300);
  }

  @override
  onInitialPage(List<Findable> items) {
    _setInvoices(items);
  }

  @override
  onPage(List<Findable> items) {
    _setInvoices(items);
  }

  void _setInvoices(List<Findable> items) {
    currentPage.clear();
    items.forEach((f) {
      currentPage.add(f);
    });
    setState(() {});
  }

  //paging constructs
  BasePager basePager;
  void _setBasePager() {
    if (appModel == null) return;
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.invoices,
        pageLimit: pageLimit,
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
    if (appModel.invoices == null) return 0.00;
    var t = 0.0;
    appModel.invoices.forEach((po) {
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
    if (this.pageLimit == pageLimit) {
      return null;
    }
    this.pageLimit = pageLimit;
    _pageNumber = 1;
    basePager = BasePager(
      items: appModel.invoices,
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

}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  final double elevation;
  InvoiceCard({this.invoice, this.context, this.elevation});

  @override
  Widget build(BuildContext context) {
    String amount;
    String _getFormattedAmt() {
      amount = '${invoice.totalAmount}';
      return amount;
    }

    double width = 80.0;
    amount = _getFormattedAmt();
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: Card(
        elevation: elevation == null ? 1.0 : elevation,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        invoice.itemNumber == null
                            ? '0'
                            : '${invoice.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                    ),
                    Text(
                      getFormattedDateLongWithTime(invoice.date, context),
                      style: Styles.blackSmall,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: Text(
                          invoice.supplierName,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 4.0, top: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: width,
                      child: Text(
                        'Amount',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        amount == null
                            ? '0.00'
                            : getFormattedAmount('$amount', context),
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade200),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 4.0, top: 0.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: width,
                      child: Text(
                        'Invoice No:',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice == null ? '0.00' : invoice.invoiceNumber,
                        style: Styles.blackSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 0.0, top: 4.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: width,
                        child: Text(
                          'Accepted',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    Text(
                      invoice.invoiceAcceptance.trim() == 'n/a' ? 'NO' : 'YES',
                      style: Styles.blackSmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Opacity(
                        opacity: invoice.invoiceAcceptance.trim() == 'n/a'
                            ? 0.0
                            : 1.0,
                        child: Icon(
                          Icons.done,
                          size: 24.0,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: width,
                        child: Text(
                          'Settled',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    Text(
                      invoice.isSettled == false ? 'NO' : 'YES',
                      style: Styles.blackSmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Opacity(
                        opacity: invoice.isSettled == true ? 1.0 : 0.0,
                        child: Icon(
                          Icons.done,
                          color: Colors.teal,
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
    );
  }
}
