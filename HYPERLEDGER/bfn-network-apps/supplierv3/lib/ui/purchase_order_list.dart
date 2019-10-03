import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  final SupplierApplicationModel model;

  PurchaseOrderListPage({this.model});

  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements SnackBarListener, POListener, PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PurchaseOrder> currentPage = List(), baseList;
  FirebaseMessaging _fcm = FirebaseMessaging();

  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  Supplier supplier;
  bool isPurchaseOrder = false, isDeliveryAcceptance = false;
  DeliveryAcceptance acceptance;
  User user;
  PurchaseOrderSummary summary;
  int pageLimit;
  int lastDate;
  bool isBackPressed = false;
  int previousStartKey;
  FCM _fm = FCM();
  @override
  void initState() {
    super.initState();
    _getCached();
    setBasePager();
  }

  void _getCached() async {
    supplier = await SharedPrefs.getSupplier();
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
    print('\n\n_PurchaseOrderListPageState._getCached SUBSCRIBED to PO topic');
//    setState(() {});
  }

  BasePager basePager;
  void setBasePager() {
    if (widget.model == null) return;
    print(
        '_PurchaseOrderList.setBasePager appModel.pageLimit: ${widget.model.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: widget.model.purchaseOrders,
        pageLimit: widget.model.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
    setState(() {});
  }

  double _getPageValue() {
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  double _getTotalValue() {
    var t = 0.0;
    widget.model.purchaseOrders.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  int _pageNumber = 1;
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(220.0),
      child: widget.model == null
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
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 12.0),
                  child: PagerControl(
                    itemName: 'Purchase Orders',
                    pageLimit: widget.model.pageLimit,
                    elevation: 16.0,
                    items: widget.model.purchaseOrders.length,
                    listener: this,
                    color: Colors.pink.shade50,
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

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Purchase Orders'),
        bottom: _getBottom(),
      ),
      backgroundColor: Colors.brown.shade100,
      body: Container(
//        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Flexible(
                child: _getListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          return PurchaseOrderCard(
            purchaseOrder: currentPage.elementAt(index),
            listener: this,
            elevation: elevation,
          );
        });
  }

  double elevation = 2.0;

  @override
  onActionPressed(int action) {
    print('_PurchaseOrderListPageState.onActionPressed ...........');
    if (isDeliveryAcceptance) {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new NewInvoicePage(acceptance)),
      );
    }
    if (isPurchaseOrder) {
      currentPage.insert(0, purchaseOrder);
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new PurchaseOrderListPage()),
      );
    }
  }

  @override
  onCreateDeliveryNote(PurchaseOrder po) {
    print('_PurchaseOrderListPageState._onDeliveryNote');
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return new DeliveryNotePage(po);
    }));
  }

  @override
  onDocumentUpload(PurchaseOrder po) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Upload Under Constructtion',
        textColor: Colors.white,
        backgroundColor: Colors.black);
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
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
    await widget.model.updatePageLimit(pageLimit);
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

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;
  final POListener listener;
  final double elevation;

  PurchaseOrderCard(
      {@required this.purchaseOrder,
      @required this.listener,
      @required this.elevation});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 2.0,
        color: Colors.brown.shade50,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, top: 10.0, bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${purchaseOrder.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          getFormattedDateLongWithTime(
                              '${purchaseOrder.date}', context),
                          style: Styles.blackSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      purchaseOrder.purchaserName == null
                          ? 'Unknown Purchaser'
                          : purchaseOrder.purchaserName,
                      style: Styles.blackBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      purchaseOrder.purchaseOrderNumber,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                    child: Text(
                      getFormattedAmount('${purchaseOrder.amount}', context),
                      style: Styles.tealBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            _getActions(),
          ],
        ),
      ),
    );
  }

  Widget _getActions() {
    assert(purchaseOrder != null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 12.0),
      child: Row(
        children: <Widget>[
          FlatButton(
            onPressed: _uploadPOdoc,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.cloud_upload),
                ),
                Text(
                  'Upload PO',
                  style: Styles.greyLabelSmall,
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: _createNote,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.create),
                    ),
                    Text(
                      'Delivery Note',
                      style: Styles.greyLabelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _uploadPOdoc() {
    listener.onDocumentUpload(purchaseOrder);
  }

  void _createNote() {
    listener.onCreateDeliveryNote(purchaseOrder);
  }
}

abstract class POListener {
  onDocumentUpload(PurchaseOrder po);
  onCreateDeliveryNote(PurchaseOrder po);
}
