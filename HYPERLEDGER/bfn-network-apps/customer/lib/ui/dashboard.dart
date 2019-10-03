import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/constants.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/message.dart';
import 'package:businesslibrary/util/my_transition.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/support/contact_us.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/customer_bloc.dart';
import 'package:customer/ui/delivery_note_list.dart';
import 'package:customer/ui/invoice_list.dart';
import 'package:customer/ui/purchase_order_list.dart';
import 'package:customer/ui/settlements.dart';
import 'package:customer/ui/summary_card.dart';
import 'package:customer/ui/theme_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final String message;

  Dashboard(this.message);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin
    implements SnackBarListener {
  static const actionPayments = 1,
      actionInvoices = 2,
      actionPurchaseOrders = 3,
      actionDeliveryNotes = 4,
      actionDeliveryAcceptances = 5;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  AnimationController animationController;
  Animation<double> animation;
  Customer customer;
  User user;
  String fullName;
  int messageReceived;
  String message;
  bool listenersStarted = false;
  CustomerApplicationModel appModel;
  String token;

  @override
  initState() {
    super.initState();
    customerBloc.fixUsers();
    print(' 🏀 _DashboardState.initState ..... to get summary');
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);

    _getCachedPrefs();
    appModel = customerBloc.appModel;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _getCachedPrefs() async {
    customer = await SharedPrefs.getCustomer();
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    _configureFCM();
  }

  //FCM methods #############################
  _configureFCM() async {
    print(
        '\n\n\🌺 🌺 🌺  ################ CONFIGURE FCM MESSAGE ###########  🌺 🌺 🌺 ');

    token = await _fcm.getToken();
    if (token != null) {
      SharedPrefs.saveFCMToken(token);
    }
    bool isRunningIOs = await isDeviceIOS();

    _fcm.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n🌺 🌺 🌺 ################ Message from FCM ################# 💙 💙 ${DateTime.now().toIso8601String()} 💙 💙 ');

        String messageType = 'unknown';
        String mJSON;
        try {
          if (isRunningIOs == true) {
            messageType = map["messageType"];
            mJSON = map['json'];
            print('FCM.configureFCM 🌽 🌽 🌽 platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('FCM.configureFCM 🌽 🌽 🌽  platform is Android');
          }
        } catch (e) {
          print(e);
          print(
              'FCM.configureFCM -------- EXCEPTION handling platform detection');
        }

        print(
            '📭 📭 📭 📭  FCM MESSAGE type RECEIVED: 👽 👽 👽 👽 messageType: 🏓 $messageType');

        try {
          switch (messageType) {
            case FS_PURCHASE_ORDERS:
              var m = PurchaseOrder.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\nFCM ## 👽 👽 👽 👽  -  🌼 🌺  PURCHASE_ORDER MESSAGE :');
              customerBloc.receivePurchaseOrderMessage(m, context);
              onPurchaseOrderMessage(m);
              break;
            case FS_DELIVERY_NOTES:
              var m = DeliveryNote.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\nFCM ## 👽 👽 👽 👽  -  🌼 🌺  DELIVERY_NOTE MESSAGE :');
              customerBloc.receiveDeliveryNoteMessage(m, context);
              onDeliveryNoteMessage(m);
              break;
            case FS_DELIVERY_ACCEPTANCES:
              var m = DeliveryAcceptance.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\nFCM ## 👽 👽 👽 👽  -  🌼 🌺  DELIVERY_ACCEPTANCE MESSAGE :');
              customerBloc.receiveDeliveryAcceptanceMessage(m, context);
              onDeliveryAcceptanceMessage(m);
              break;
            case FS_INVOICES:
              var m = Invoice.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\nFCM ## 👽 👽 👽 👽  -  🌼 🌺  MINVOICE ESSAGE :');
              customerBloc.receiveInvoiceMessage(m, context);
              onInvoiceMessage(m);
              break;
            case FS_INVOICE_ACCEPTANCES:
              var m = InvoiceAcceptance.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  'FCM ## 👽 👽 👽 👽 - 🏓 🏓 🏓 FCM INVOICE_ACCEPTANCE MESSAGE :');
              customerBloc.receiveInvoiceAcceptanceMessage(m, context);
              onInvoiceAcceptanceMessage(m);
              break;

            case FS_SETTLEMENTS:
              Map map = json.decode(mJSON);
              prettyPrint(map,
                  '\n\nFCM ## 👽 👽 👽 👽  -  🌼 🌺  INVESTOR_INVOICE_SETTLEMENT :');
              onInvestorInvoiceSettlement(
                  InvestorInvoiceSettlement.fromJson(map));
              break;
          }
        } catch (e) {
          print(
              'FCM.configureFCM - 👿 👿 👿Houston, we have a problem with null listener 👿 somewhere');
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print('📭 📭 configureMessaging onLaunch *********** ');
        prettyPrint(message, 'message delivered on LAUNCH!');
      },
      onResume: (Map<String, dynamic> message) {
        print('📭 📭 configureMessaging onResume *********** ');
        prettyPrint(message, 'message delivered on RESUME!');
      },
    );

    _fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
    _subscribeToFCMTopics();
  }

  _subscribeToFCMTopics() async {
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + customer.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_DELIVERY_ACCEPTANCES + customer.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVOICE_ACCEPTANCES + customer.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);

//    _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + govtEntity.participantId);
//    _fcm.subscribeToTopic(FCM.TOPIC_OFFERS + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + customer.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_DELIVERY_NOTES + customer.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVESTOR_INVOICE_SETTLEMENTS + customer.participantId);
    print(
        '\n\n📭 📭 📭 _DashboardState._subscribeToFCMTopics SUBSCRIBED to topis - 🔆 Offers, 🔆  Invoicesn 🔆 POs, 🔆 Delivery acceptance, 🔆 Invoice acceptance');
  }
  //end of FCM methods ######################

  Firestore fs = Firestore.instance;

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  customer == null ? 'Customer Name' : customer.name,
                  style: Styles.whiteBoldMedium,
                ),
              )
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

  void _onChangeTheme() async {
    print('_DashboardState._onChangeTheme +++++++++++++++++++++++');
    themeBloc.changeToRandomTheme();
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
    message = widget.message;
    _configureFCM();
    return StreamBuilder<CustomerApplicationModel>(
      initialData: customerBloc.appModel,
      stream: customerBloc.appModelStream,
      builder: (context, snapshot) {
        appModel = snapshot.data;
        customer = appModel.customer;
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Houston, we got a Stream problem!',
              style: Styles.pinkBoldMedium,
            ),
          );
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.done:
            break;
          case ConnectionState.waiting:
            break;
          case ConnectionState.active:
            print(
                '_DashboardState.build ☘ ☘ ☘ ################## ConnectionState.active');
            break;
        }
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 8.0,
//              backgroundColor: Colors.brown.shade200,
              title: Text(
                '☘Customer',
                style: TextStyle(fontWeight: FontWeight.w100),
              ),
              leading:
                  IconButton(icon: Icon(Icons.apps), onPressed: _onChangeTheme),
              bottom: _getBottom(),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _onRefreshPressed,
                ),
                IconButton(
                  icon: Icon(Icons.help),
                  onPressed: _goToContactPage,
                ),
              ],
            ),
            backgroundColor: Colors.brown.shade100,
            body: Stack(
              children: <Widget>[
                new Opacity(
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/fincash.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                _getListView(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getListView() {
    List<ListTile> tiles = List();
    if (messages != null) {
      messages.forEach((m) {
        var tile = ListTile(
          title: Text(m.message),
          subtitle: Text(
            m.subTitle,
            style: Styles.blackBoldSmall,
          ),
          leading: m.icon,
        );

        tiles.add(tile);
      });
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: appModel == null
          ? Container(
              child: Center(
                child: Text(
                  'App Model is Loading ...',
                  style: Styles.blackBoldLarge,
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                new InkWell(
                  onTap: _onInvoicesTapped,
                  child: SummaryCard(
                      total: appModel.invoices == null
                          ? 0
                          : appModel.invoices.length,
                      label: 'Invoices',
                      totalStyle: Styles.pinkBoldLarge,
                      totalValue: appModel.invoices == null
                          ? 0.0
                          : appModel.getTotalInvoiceAmount(),
                      totalValueStyle: Styles.blackBoldMedium,
                      elevation: 16.0,
                      color: Colors.orange.shade100),
                ),
                new InkWell(
                  onTap: _onPurchaseOrdersTapped,
                  child: SummaryCard(
                    total: appModel.purchaseOrders == null
                        ? 0
                        : appModel.purchaseOrders.length,
                    label: 'Purchase Orders',
                    totalStyle: Styles.tealBoldLarge,
                    totalValue: appModel.purchaseOrders == null
                        ? 0.0
                        : appModel.getTotalPurchaseOrderAmount(),
                    elevation: 2.0,
                  ),
                ),
                new InkWell(
                  onTap: _onDeliveryNotesTapped,
                  child: SummaryCard(
                    total: appModel.deliveryNotes == null
                        ? 0
                        : appModel.deliveryNotes.length,
                    label: 'Delivery Notes',
                    totalStyle: Styles.blackBoldLarge,
                    totalValue: appModel.deliveryNotes == null
                        ? 0.0
                        : appModel.getTotalDeliveryNoteAmount(),
                    elevation: 2.0,
                  ),
                ),
                new InkWell(
                  onTap: _onPaymentsTapped,
                  child: SummaryCard(
                    total: appModel.settlements == null
                        ? 0
                        : appModel.settlements.length,
                    label: 'Settlements',
                    totalStyle: Styles.blueBoldLarge,
                    totalValueStyle: Styles.blackBoldMedium,
                    elevation: 8.0,
                    totalValue: appModel.settlements == null
                        ? 0.0
                        : appModel.getTotalSettlementAmount(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: tiles,
                  ),
                ),
              ],
            ),
    );
  }

  void _goToContactPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(context, SlideRightRoute(widget: ContactUs()));
  }

  void _onInvoicesTapped() {
    print('_MainPageState._onInvoicesTapped ... go  to list of invoices');
    Navigator.push(
      context,
      SlideRightRoute(widget: InvoiceList()),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      SlideRightRoute(widget: PurchaseOrderListPage()),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      SlideRightRoute(widget: DeliveryNoteList()),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
    Navigator.push(
      context,
      SlideRightRoute(widget: SettlementList()),
    );
  }

  @override
  onActionPressed(int action) {
    print('_DashboardState.onActionPressed action: $action');

    switch (action) {
      case DeliveryNoteConstant:
        _onDeliveryNotesTapped();
        break;
      case InvoiceConstant:
        _onInvoicesTapped();
        break;
    }
  }

  onDeliveryNoteMessage(DeliveryNote deliveryNote) {
    prettyPrint(deliveryNote.toJson(), '#### Delivery Note Arrived');
    setState(() {
      messages.add(Message(
          type: Message.DELIVERY_NOTE,
          message:
              'Delivery Note arrived: ${getFormattedDateShortWithTime('${deliveryNote.date}', context)} ',
          subTitle: deliveryNote.supplierName));
    });
//    _showSnack(message: messages.last.message);
    customerBloc.refreshDeliveryNotes();
  }

  onInvoiceMessage(Invoice invoice) async {
    setState(() {
      messages.add(Message(
          type: Message.INVOICE,
          message:
              'Invoice arrived: ${getFormattedDateShortWithTime('${invoice.date}', context)} ',
          subTitle: invoice.supplierName));
    });
//    _showSnack(message: messages.last.message);
    customerBloc.refreshInvoices();
  }

  onGeneralMessage(Map map) {
    setState(() {
      messages.add(Message(
        type: Message.GENERAL_MESSAGE,
        message: map['message'],
      ));
    });
    setState(() {});
//    _showSnack(message: messages.last.message);
  }

  void onInvestorInvoiceSettlement(InvestorInvoiceSettlement settlement) async {
    setState(() {
      messages.add(Message(
          type: Message.SETTLEMENT,
          message:
              'Settlement arrived: ${getFormattedDateShortWithTime('${settlement.date}', context)} ',
          subTitle:
              settlement.supplierName + " from ${settlement.investorName}"));
    });
    _showSnack(message: messages.last.message);
    await customerBloc.refreshSettlements();
    setState(() {});
  }

  void onInvoiceBidMessage(InvoiceBid bid) async {
    setState(() {
      messages.add(Message(
          type: Message.INVOICE_BID,
          message:
              'Invoice Bid arrived: ${getFormattedDateShortWithTime('${bid.date}', context)} ',
          subTitle: bid.investorName));
    });
//    _showSnack(message: messages.last.message);
    //await customerModelBloc.refreshModel();
    setState(() {});
  }

  void onOfferMessage(Offer o) async {
    setState(() {
      messages.add(Message(
          type: Message.OFFER,
          message:
              'Offer arrived: ${getFormattedDateShortWithTime('${o.date}', context)} ',
          subTitle: o.supplierName +
              ' ${getFormattedAmount('${o.offerAmount}', context)}'));
    });
//    _showSnack(message: messages.last.message);
    await customerBloc.refreshOffers();
    setState(() {});
  }

  void onInvoiceAcceptanceMessage(InvoiceAcceptance acc) async {
    setState(() {
      messages.add(Message(
          type: Message.INVOICE_ACCEPTANCE,
          message:
              'Invoice Acceptance arrived: ${getFormattedDateShortWithTime('${acc.date}', context)} ',
          subTitle: acc.customerName));
    });
//    _showSnack(message: messages.last.message);
    await customerBloc.refreshInvoiceAcceptances();
    setState(() {});
  }

  void onDeliveryAcceptanceMessage(DeliveryAcceptance acc) async {
    setState(() {
      messages.add(Message(
          type: Message.DELIVERY_ACCEPTANCE,
          message:
              'Delivery Acceptance arrived: ${getFormattedDateShortWithTime('${acc.date}', context)} ',
          subTitle: acc.customerName));
    });
//    _showSnack(message: messages.last.message);
    await customerBloc.refreshDeliveryAcceptances();
    setState(() {});
  }

  void onPurchaseOrderMessage(PurchaseOrder po) {
    setState(() {
      messages.add(Message(
          type: Message.PURCHASE_ORDER,
          message:
              'Purchase Order arrived: ${getFormattedDateShortWithTime('${po.date}', context)} ',
          subTitle: po.supplierName));
    });
//    _showSnack(message: messages.last.message);
    customerBloc.refreshPurchaseOrders();
    setState(() {});
  }

  List<Message> messages = List();
  void _showSnack(
      {@required String message, Color textColor, Color backColor}) {
    AppSnackBar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: textColor == null ? Colors.white : textColor,
        backgroundColor: backColor == null ? Colors.black : backColor);
  }
}

class DashboardCard extends StatelessWidget {
  final String countTitle, totalTitle;
  final int count;
  final double total;
  final Color countColor, totalColor, cardColor;

  DashboardCard(this.countTitle, this.totalTitle, this.count, this.total,
      this.countColor, this.totalColor, this.cardColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.0,
      child: Card(
        elevation: 2.0,
        child: Column(
          children: <Widget>[
            Text(''),
          ],
        ),
      ),
    );
  }
}
