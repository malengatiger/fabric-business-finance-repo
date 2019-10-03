import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:customer/customer_bloc.dart';
import 'package:customer/ui/purchase_order_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  List<PurchaseOrder> currentPage;
  Customer entity;
  PurchaseOrderSummary poSummary;
  CustomerApplicationModel appModel;

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  _getCached() async {
    appModel = customerBloc.appModel;
    entity = appModel.customer;
    setBasePager();
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() {
    if (appModel == null) return;
    print(
        '_PurchaseOrderListPageState.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.purchaseOrders,
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
      t += po.amount;
    });
    return t;
  }

  double _getTotalValue() {
    if (appModel == null) return 0.00;
    var t = 0.0;
    appModel.purchaseOrders.forEach((po) {
      t += po.amount;
    });
    return t;
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
    print('_PurchaseOrderListPageState.onPageLimit');
    await appModel.updatePageLimit(pageLimit);
    basePager.getNextPage();
    return null;
  }

  @override
  onPreviousPageRequired() {
    print('__PurchaseOrderListPageState.onPreviousPageRequired');
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

  int _pageNumber = 1;
//end of paging constructs
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(220.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: appModel == null
                ? Container()
                : Column(
                    children: <Widget>[
                      PagingTotalsView(
                        pageValue: _getPageValue(),
                        totalValue: _getTotalValue(),
                        labelStyle: Styles.blackSmall,
                        pageValueStyle: Styles.blackBoldLarge,
                        totalValueStyle: Styles.brownBoldMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                        child: PagerControl(
                          listener: this,
                          itemName: 'Purchase Orders',
                          pageLimit: appModel.pageLimit == null
                              ? 4
                              : appModel.pageLimit,
                          items: appModel.purchaseOrders.length,
                          pageNumber: _pageNumber,
                        ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Purchase Orders',
          style: Styles.blackBoldMedium,
        ),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddPurchaseOrder,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              customerBloc.refreshModel();
            },
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: _getListView(),
            ),
          ],
        ),
      ),
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
              onTap: _onPurchaseOrderTapped,
              child: new PurchaseOrderCard(currentPage.elementAt(index)));
        });
  }

  void _onAddPurchaseOrder() async {
    print('_PurchaseOrderListPageState._onAddPurchaseOrder .......');
    purchaseOrder = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new PurchaseOrderPage(getURL())),
    );
    if (purchaseOrder != null) {
      AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order submitted successfully',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void _onPurchaseOrderTapped() {}
  @override
  onDeliveryNoteMessage(DeliveryNote deliveryNote) {
    prettyPrint(deliveryNote.toJson(), '### Delivery Note Arrived');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note Arrived',
        textColor: Styles.lightBlue,
        backgroundColor: Styles.black);
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    prettyPrint(invoice.toJson(), '### Invoice Arrived');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
  }
}

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;

  PurchaseOrderCard(this.purchaseOrder);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child: Card(
        elevation: 2.0,
        color: Colors.brown.shade50,
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, bottom: 10.0, top: 20.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      purchaseOrder.itemNumber == null
                          ? '0'
                          : '${purchaseOrder.itemNumber}',
                      style: Styles.blackBoldSmall,
                    ),
                  ),
                  Text(
                    getFormattedDateLongWithTime(purchaseOrder.date, context),
                    style: Styles.blackSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0.0,
              ),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.apps,
                      color: getRandomColor(),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      purchaseOrder.supplierName == null
                          ? 'Unknown Supplier'
                          : purchaseOrder.supplierName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, bottom: 20.0, top: 4.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      purchaseOrder.purchaseOrderNumber,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      getFormattedAmount('${purchaseOrder.amount}', context),
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
