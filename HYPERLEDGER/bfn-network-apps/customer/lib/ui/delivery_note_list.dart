import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:customer/customer_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DeliveryNoteList extends StatefulWidget {
  @override
  _DeliveryNoteListState createState() => _DeliveryNoteListState();
}

class _DeliveryNoteListState extends State<DeliveryNoteList>
    implements
        SnackBarListener,
        PagerControlListener,
        DeliveryNoteCardListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  List<Supplier> suppliers;
  User user;
  Customer customer;
  CustomerApplicationModel appModel;
  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    customer = await SharedPrefs.getCustomer();
    appModel = customerBloc.appModel;
    setBasePager();
  }

  void _onRefreshPressed() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Refreshing data ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    await customerBloc.refreshModel();
    _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('☘ Delivery Notes', style: Styles.whiteBoldMedium),
        bottom: _getBottom(),
        backgroundColor: Colors.indigo.shade200,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _onRefreshPressed),
        ],
      ),
      body: Container(
        color: Colors.brown.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: _getListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: new Size.fromHeight(220.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          appModel == null
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
                          bottom: 12.0, left: 12.0, right: 12),
                      child: PagerControl(
                        itemName: 'Delivery Notes',
                        pageLimit: appModel.pageLimit,
                        elevation: 8.0,
                        items: appModel.deliveryNotes.length,
                        listener: this,
                        color: Colors.purple.shade50,
                        pageNumber: _pageNumber,
                      ),
                    ),
                  ],
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

  ScrollController controller1 = ScrollController();
  List<DeliveryNote> currentPage;
  Widget _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.minScrollExtent,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    });
    if (appModel == null || currentPage == null) {
      return Container();
    }
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: controller1,
        itemBuilder: (BuildContext context, int index) {
          return new DeliveryNoteCard(
              deliveryNote: currentPage.elementAt(index), listener: this);
        });
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() {
    if (appModel == null) return;
    print(
        '_DeliveryNoteListState.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.deliveryNotes,
        pageLimit: appModel.pageLimit,
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
    appModel.deliveryNotes.forEach((po) {
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

//end of paging constructs
  DeliveryNote deliveryNote;
  @override
  onActionPressed(int action) {
    print('_DeliveryNoteListState.onActionPressed');
    Navigator.pop(context);
  }

  static const Namespace = 'resource:com.oneconnect.biz.';
  void _acceptDelivery() async {
    Navigator.pop(context);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Delivery Acceptance ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    DeliveryAcceptance acceptance = DeliveryAcceptance(
      date: getUTCDate(),
      supplier: deliveryNote.supplier,
      purchaseOrder: deliveryNote.purchaseOrder,
      customer: deliveryNote.customer,
      user: user.userId,
      deliveryNote: deliveryNote.deliveryNoteId,
      customerName: deliveryNote.customerName,
      purchaseOrderNumber: deliveryNote.purchaseOrderNumber,
    );

    try {
      await DataAPI3.acceptDelivery(acceptance);
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery  Note accepted',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'DONE',
          listener: this,
          action: 0,
          icon: Icons.done);
    } catch (e) {
      print('_DeliveryNoteListState._acceptDelivery ERROR $e');
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Acceptance failed',
          listener: this,
          actionLabel: 'ERROR');
    }
  }

  @override
  onNoteTapped(DeliveryNote note) {
    this.deliveryNote = note;

    prettyPrint(deliveryNote.toJson(),
        '_DeliveryNoteListState.onDeliveryNoteTapped ...');

    _checkDeliveryNote();
  }

  void showAcceptDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Confirm Delivery Acceptance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    new Text("Do you want to accept this Delivery Note?\n\ "),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Purchase Order:',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${deliveryNote.purchaseOrderNumber}',
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
                    onPressed: _acceptDelivery,
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

  void _checkDeliveryNote() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking Delivery Note ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    var noteAcceptance =
        await ListAPI.getDeliveryAcceptanceForNote(deliveryNote.deliveryNoteId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (noteAcceptance != null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery note already accepted',
          textColor: Colors.white,
          backgroundColor: Colors.black);
    } else {
      showAcceptDialog();
    }
  }

  int pageLimit;
}

class DeliveryNoteCard extends StatelessWidget {
  final DeliveryNote deliveryNote;
  final DeliveryNoteCardListener listener;

  DeliveryNoteCard({@required this.deliveryNote, @required this.listener});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onBigTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
        child: Card(
          elevation: 2.0,
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        deliveryNote.itemNumber == null
                            ? '0'
                            : '${deliveryNote.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                    ),
                    Text(
                      getFormattedDateLongWithTime(deliveryNote.date, context),
                      style: Styles.blackSmall,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        deliveryNote.supplierName,
                        style: Styles.blackBoldMedium,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'PO Number',
                            style: Styles.blackSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text(
                            deliveryNote.purchaseOrderNumber,
                            style: Styles.blackSmall,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Note Amount',
                            style: Styles.blackSmall,
                          ),
                        ),
                        Text(
                          deliveryNote.amount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${deliveryNote.amount}', context),
                          style: Styles.blackSmall,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Note VAT',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Text(
                        deliveryNote.vat == null
                            ? '0.00'
                            : getFormattedAmount(
                                '${deliveryNote.vat}', context),
                        style: Styles.blackSmall,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Note Total',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Text(
                        deliveryNote.totalAmount == null
                            ? '0.00'
                            : getFormattedAmount(
                                '${deliveryNote.totalAmount}', context),
                        style: Styles.tealBoldMedium,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBigTap() {
    print('DeliveryNoteCard._onBigTap .........................');
    listener.onNoteTapped(deliveryNote);
  }
}

abstract class DeliveryNoteCardListener {
  onNoteTapped(DeliveryNote note);
}
