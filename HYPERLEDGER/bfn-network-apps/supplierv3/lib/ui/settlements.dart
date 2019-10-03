import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/supplier_bloc.dart';

class SettlementList extends StatefulWidget {
  final SupplierApplicationModel model;

  SettlementList(this.model);

  @override
  _SettlementListState createState() => _SettlementListState();
}

class _SettlementListState extends State<SettlementList>
    implements PagerControlListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();

  BasePager basePager;
  List<InvestorInvoiceSettlement> currentPage;

  @override
  void initState() {
    super.initState();
    setBasePager();
  }

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
                    itemName: 'Settlements',
                    pageLimit: widget.model.pageLimit,
                    elevation: 16.0,
                    items: widget.model.settlements.length,
                    listener: this,
                    color: Colors.brown.shade100,
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

  //paging constructs
  void setBasePager() {
    if (widget.model == null) return;
    print(
        'Settlements.setBasePager appModel.pageLimit: ${widget.model.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: widget.model.settlements,
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
    if (currentPage == null) return 0.00;
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  double _getTotalValue() {
    if (widget.model == null) return 0.00;
    var t = 0.0;
    widget.model.deliveryNotes.forEach((po) {
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

//end of paging constructs
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Offer Settlements"),
        bottom: _getBottom(),
      ),
      body: _getListView(),
    );
  }

  double elevation = 4.0;
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
          return SettlementCard(
            settlement: currentPage.elementAt(index),
          );
        });
  }
}

class SettlementCard extends StatelessWidget {
  final InvestorInvoiceSettlement settlement;

  SettlementCard({this.settlement});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Row(),
          Row(),
        ],
      ),
    );
  }
}
