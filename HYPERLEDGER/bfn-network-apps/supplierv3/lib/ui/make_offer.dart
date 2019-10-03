import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/file_util.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/supplier_bloc.dart';

class MakeOfferPage extends StatefulWidget {
  final Invoice invoice;

  MakeOfferPage(this.invoice);
  static _MakeOfferPageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_MakeOfferPageState>());

  @override
  _MakeOfferPageState createState() => _MakeOfferPageState();
}

class _MakeOfferPageState extends State<MakeOfferPage>
    implements SnackBarListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();

  Invoice invoice;
  Supplier supplier;
  PurchaseOrder purchaseOrder;
  User user;
  String percentage;
  DateTime startTime = DateTime.now(),
      initialDate = DateTime.now().add(Duration(seconds: 365)),
      endTime = DateTime.now().add(Duration(days: 14));
  int days;
  List<DropdownMenuItem<String>> items = List();
  List<String> discountStrings = List();
  String supplierAmount, investorAmount;
  Wallet wallet;
  Sector sector;
  List<Sector> sectors = List();
  String offerId;
  Offer resultOffer;
  FCM _fm = FCM();
  @override
  initState() {
    super.initState();
    _buildDiscountDropDownItems();
    _getSupplier();
    _calculateDays();
    _getSectors();
  }

  _getSectors() async {
    sectors = await FileUtil.getSector();
    setState(() {});
    if (sectors == null) {
      sectors = await ListAPI.getSectors();
      if (sectors.isNotEmpty) {
        await FileUtil.saveSectors(Sectors(sectors));
        setState(() {});
      }
    }
  }

  List<DropdownMenuItem<Sector>> sectorItems = List();
  Widget _buildDropDown() {
    if (sectors == null || sectors.isEmpty) {
      return Container();
    }
    sectors.forEach((s) {
      var item = DropdownMenuItem<Sector>(
        value: s,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.apps,
                color: Colors.blue,
              ),
            ),
            Text('${s.sectorName}'),
          ],
        ),
      );
      sectorItems.add(item);
    });
    return DropdownButton(
        items: sectorItems,
        hint: Text(
          'Select Customer Sector',
          style: Styles.whiteMedium,
        ),
        onChanged: _onSector);
  }

  _getSupplier() async {
    supplier = await SharedPrefs.getSupplier();
    user = await SharedPrefs.getUser();

    var offers = await ListAPI.getOpenOffersBySupplier(supplier.participantId);
    offers.forEach((o) {
      _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + o.offerId);
    });
    print(
        '_MakeOfferPageState._getSupplier SUBSCRIBED to ${offers.length} INVOICE BID topics');
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
  }

  _getStartTime() async {
    startTime = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: new DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now().add(Duration(seconds: 10)),
    );
    _calculateDays();
    setState(() {});
  }

  var style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  _getEndTime() async {
    endTime = await showDatePicker(
      context: context,
      firstDate: new DateTime.now(),
      lastDate: new DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now().add(Duration(seconds: 10)),
    );
    _calculateDays();
    setState(() {});
  }

  _calculateDays() {
    if (startTime != null && endTime != null) {
      var dur = endTime.difference(startTime);
      days = dur.inDays;
      setState(() {});
    }
  }

  _calculateExpected() {
    if (percentage != null) {
      double offerPercentage = double.parse(percentage);
      offerPercentage = 100.0 - offerPercentage;

      double offerAmt = invoice.totalAmount * (offerPercentage / 100);

      setState(() {
        investorAmount = '$offerAmt';
      });
    }
  }

  bool submitting = false;

  _refreshData() async {
    await supplierBloc.refreshModel();
  }

  _submitOffer() async {
    print(
        'MakeOfferPage._submitOffer ########### invoice: ${invoice.invoiceNumber} --------------\n\n');
    if (submitting) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already submitted',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (sector == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select Customer Sector',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (percentage == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select Offer Percentage',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    //todo - check if offer already exists
    var off = await ListAPI.checkOfferByInvoice(invoice.invoiceId);
    if (off != null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already exists',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    submitting = true;
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Invoice Offer ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    var disc = double.parse(percentage);

    var offerAmt = (invoice.totalAmount * (100.0 - disc)) / 100.0;
    wallet = await SharedPrefs.getWallet();
    if (wallet == null) {
      wallet = await ListAPI.getWallet(participantId: supplier.participantId);
    }
    var startTime = DateTime.now().toUtc();
    var endTime = startTime.add(new Duration(days: days)).toIso8601String();

    var token = await _fcm.getToken();
    Offer offer = new Offer(
        supplier: supplier.participantId,
        invoice: invoice.invoiceId,
        user: user.userId,
        purchaseOrder: invoice.purchaseOrder,
        offerAmount: offerAmt,
        invoiceAmount: invoice.totalAmount,
        discountPercent: disc,
        startTime: getUTCDate(),
        endTime: endTime,
        participantId: supplier.participantId,
        customerName: invoice.customerName,
        customer: invoice.customer,
        supplierName: supplier.name,
        sector: sector.sectorId,
        sectorName: sector.sectorName);
    if (wallet != null) {
      offer.wallet = wallet.stellarPublicKey;
    }

    print(
        '_MakeOfferPageState._submitOffer about to open snackbar ===================>');

    var x = await ListAPI.findOfferByInvoice(offer.invoice);
    if (x != null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already exists',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    try {
      resultOffer = await DataAPI3.makeOffer(offer);

      offerId = resultOffer.offerId;
      FirebaseMessaging mg = FirebaseMessaging();
      mg.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + offerId);
      needRefresh = true;
      await _refreshData();

      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Ivoice Offer submitted OK',
          textColor: Colors.white,
          backgroundColor: Colors.teal.shade800,
          actionLabel: "DONE",
          listener: this,
          action: OfferSubmitted,
          icon: Icons.done);
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Offer failed',
          listener: this,
          actionLabel: 'Close');
      needRefresh = false;
      submitting = false;
    }
  }

  static const OfferSubmitted = 1;
  bool needRefresh = false;
  @override
  Widget build(BuildContext context) {
    invoice = widget.invoice;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Make Offer',
          style: Styles.whiteBoldMedium,
        ),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                _buildDropDown(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    sector == null ? '' : sector.sectorName,
                    style: Styles.whiteBoldMedium,
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
            preferredSize: Size.fromHeight(110.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: ListView(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 28.0, bottom: 8.0, top: 8.0),
                child: Text(
                  invoice.customerName,
                  style: Styles.blackBoldLarge,
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Container(
                      width: 110.0,
                      child: RaisedButton(
                        onPressed: _getStartTime,
                        elevation: 4.0,
                        color: Colors.blue,
                        child: Text(
                          'Start Date',
                          style: Styles.whiteSmall,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      startTime == null
                          ? ''
                          : getFormattedDate(startTime.toIso8601String()),
                      style: Styles.blackSmall,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 28.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 110.0,
                      child: RaisedButton(
                        onPressed: _getEndTime,
                        elevation: 4.0,
                        color: Colors.teal.shade800,
                        child: Text(
                          'End Date',
                          style: Styles.whiteSmall,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        endTime == null
                            ? ''
                            : getFormattedDate(endTime.toIso8601String()),
                        style: Styles.blackSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80.0, top: 4.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      days == null ? '0' : '$days',
                      style: Styles.purpleBoldReallyLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 8.0),
                      child: Text(
                        'Days',
                        style: Styles.blackMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Container(width: 120.0, child: Text('Invoice Number')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.invoiceNumber,
                        style: Styles.blackSmall,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 28.0, top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(width: 120.0, child: Text('Invoice Amount')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        getFormattedAmount('${invoice.totalAmount}', context),
                        style: Styles.blackBoldSmall,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0),
                child: Row(
                  children: <Widget>[
                    Container(width: 120.0, child: Text('Invoice Date')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        getFormattedDateShort(invoice.date, context),
                        style: Styles.blackSmall,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                      child: DropdownButton<String>(
                        items: items,
                        onChanged: _onDiscountTapped,
                        elevation: 16,
                        hint: Text(
                          'Invoice Discount',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      percentage == null ? '' : percentage,
                      style: Styles.blackBoldLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '%',
                        style: Styles.pinkBoldLarge,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Container(width: 80.0, child: Text('Offer Amount')),
                    ),
                    Text(
                      investorAmount == null
                          ? '0.00'
                          : getFormattedAmount(investorAmount, context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 28.0, bottom: 28.0),
                  child: Opacity(
                    opacity: submitting == true ? 0.0 : 1.0,
                    child: RaisedButton(
                      elevation: 8.0,
                      onPressed: _submitOffer,
                      color: Colors.indigo.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Submit Offer',
                          style: Styles.whiteSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDiscountTapped(String value) {
    print('_MakeOfferPageState._onDiscountTapped value: $value');
    percentage = value;
    _calculateExpected();
  }

  @override
  onActionPressed(int action) async {
    print('_MakeOfferPageState.onActionPressed');
    switch (action) {
      case OfferSubmitted:
        Navigator.pop(context);
        Navigator.pop(context, needRefresh);
        break;
      default:
        Navigator.pop(context);
        Navigator.pop(context, false);
        break;
    }
  }

  void _onSector(Sector value) {
    sector = value;
    setState(() {});
  }

  void _buildDiscountDropDownItems() {
    print('_MakeOfferPageState._setItems ................');

    var item6 = DropdownMenuItem<String>(
      value: '1.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('1 %'),
        ],
      ),
    );
    items.add(item6);

    var item7 = DropdownMenuItem<String>(
      value: '2.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('2 %'),
        ],
      ),
    );
    items.add(item7);

    var item8 = DropdownMenuItem<String>(
      value: '3.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('3 %'),
        ],
      ),
    );
    items.add(item8);

    var item9 = DropdownMenuItem<String>(
      value: '4.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('4 %'),
        ],
      ),
    );
    items.add(item9);

    var item10 = DropdownMenuItem<String>(
      value: '5.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('5 %'),
        ],
      ),
    );
    items.add(item10);

    var item11 = DropdownMenuItem<String>(
      value: '6.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('6 %'),
        ],
      ),
    );
    items.add(item11);

    var item12 = DropdownMenuItem<String>(
      value: '7.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('7 %'),
        ],
      ),
    );
    items.add(item12);

    var item13 = DropdownMenuItem<String>(
      value: '8.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('8 %'),
        ],
      ),
    );
    items.add(item13);

    var item14 = DropdownMenuItem<String>(
      value: '9.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('9 %'),
        ],
      ),
    );
    items.add(item14);
    var item15 = DropdownMenuItem<String>(
      value: '10.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('10 %'),
        ],
      ),
    );
    items.add(item15);
    var item16 = DropdownMenuItem<String>(
      value: '11.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('11 %'),
        ],
      ),
    );
    items.add(item16);
    var item17 = DropdownMenuItem<String>(
      value: '12.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('12 %'),
        ],
      ),
    );
    items.add(item17);
    var item18 = DropdownMenuItem<String>(
      value: '13.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('13 %'),
        ],
      ),
    );
    items.add(item18);
    var item19 = DropdownMenuItem<String>(
      value: '14.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('14 %'),
        ],
      ),
    );
    items.add(item19);
    var x1 = DropdownMenuItem<String>(
      value: '15.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('15 %'),
        ],
      ),
    );
    items.add(x1);
    var x2 = DropdownMenuItem<String>(
      value: '16.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('16 %'),
        ],
      ),
    );
    items.add(x2);
    var x3 = DropdownMenuItem<String>(
      value: '17.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('17 %'),
        ],
      ),
    );
    items.add(x3);
    var x4 = DropdownMenuItem<String>(
      value: '18.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('18 %'),
        ],
      ),
    );
    items.add(x4);
    var x5 = DropdownMenuItem<String>(
      value: '19.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('19 %'),
        ],
      ),
    );
    items.add(x5);
    var x6 = DropdownMenuItem<String>(
      value: '20.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
          ),
          Text('20 %'),
        ],
      ),
    );
    items.add(x6);
  }

  InvoiceBid bid;
  @override
  onInvoiceBid(InvoiceBid bid) async {}

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    prettyPrint(bid.toJson(), 'Invoice Bid arrived .......');

    this.bid = bid;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Styles.white,
        backgroundColor: Styles.teal,
        actionLabel: 'Details',
        listener: this,
        icon: Icons.done_all,
        action: 1);
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    prettyPrint(purchaseOrder.toJson(), 'Purchase Order arrived .......');

    this.bid = bid;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order arrived',
        textColor: Styles.white,
        backgroundColor: Styles.teal,
        actionLabel: 'Details',
        listener: this,
        icon: Icons.done_all,
        action: 1);
  }
}
