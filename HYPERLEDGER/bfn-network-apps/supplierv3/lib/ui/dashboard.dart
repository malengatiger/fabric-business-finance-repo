import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/chat_bloc.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/constants.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/message.dart';
import 'package:businesslibrary/util/my_transition.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/support/chat_page.dart';
import 'package:businesslibrary/util/support/contact_us.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/contract_list.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/invoices_on_offer.dart';
import 'package:supplierv3/ui/make_offer.dart';
import 'package:supplierv3/ui/offer_list.dart';
import 'package:supplierv3/ui/purchase_order_list.dart';
import 'package:supplierv3/ui/summary_card.dart';

class Dashboard extends StatefulWidget {
  final String message;

  Dashboard(this.message);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin
    implements SnackBarListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');
  FirebaseMessaging _fcm = FirebaseMessaging();
  String message;
  AnimationController animationController;
  Animation<double> animation;
  Supplier supplier;
  User user;
  String fullName, fcmToken;
  DeliveryAcceptance acceptance;

  @override
  initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);

    _getCachedPrefs();
    appModel = supplierBloc.appModel;
    _configureFCM();
  }

  //FCM methods #############################
  _configureFCM() async {
    print('\n\n\📭 📭 📭 📭 📭 📭  CONFIGURE FCM MESSAGE 📭 📭 📭 📭 📭 ');

    bool isRunningIOs = await isDeviceIOS();
    fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      SharedPrefs.saveFCMToken(fcmToken);
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n📭 📭 📭 ################ 🌸 Message from FCM : ${DateTime.now().toIso8601String()}');

        String messageType = 'unknown';
        String mJSON;
        try {
          if (isRunningIOs == true) {
            messageType = map["messageType"];
            mJSON = map['json'];
            print(' 📭 📭 FCM.configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print(' 📭 📭 FCM.configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print(
              'FCM.configureFCM -------- EXCEPTION handling platform detection');
        }

        print(' 📭 📭  📭 📭 FCM.configureFCM ** 🔆 messageType: $messageType');

        try {
          switch (messageType) {
            case 'CHAT_RESPONSE':
              var m = ChatResponse.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\n🥦 🥦 🥦########## FCM CHAT_RESPONSE MESSAGE :');
              onChatResponseMessage(m);
              break;
            case FS_PURCHASE_ORDERS:
              var m = PurchaseOrder.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\n🥦 🥦 🥦########## FCM PURCHASE_ORDER MESSAGE :');
              supplierBloc.receivePurchaseOrderMessage(m, context);
              onPurchaseOrderMessage(m);
              break;
            case FS_DELIVERY_NOTES:
              var m = DeliveryNote.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\n🥦 🥦 🥦########## FCM DELIVERY_NOTE MESSAGE :');
              supplierBloc.receiveDeliveryNoteMessage(m, context);
              onDeliveryNoteMessage(m);
              break;
            case FS_DELIVERY_ACCEPTANCES:
              var m = DeliveryAcceptance.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\n🥦 🥦 🥦 ########## FCM DELIVERY_ACCEPTANCE MESSAGE :');
              supplierBloc.receiveDeliveryAcceptanceMessage(m, context);
              onDeliveryAcceptanceMessage(m);
              break;
            case FS_INVOICES:
              var m = Invoice.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n🥦 🥦 🥦 ########## FCM MINVOICE ESSAGE :');
              supplierBloc.receiveInvoiceMessage(m, context);
              onInvoiceMessage(m);
              break;
            case FS_INVOICE_ACCEPTANCES:
              var m = InvoiceAcceptance.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '🥦 🥦 🥦 FCM INVOICE_ACCEPTANCE MESSAGE :');
              supplierBloc.receiveInvoiceAcceptanceMessage(m, context);
              onInvoiceAcceptanceMessage(m);
              break;
            case FS_OFFERS:
              var m = Offer.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n🥦 🥦 🥦 ########## FCM OFFER MESSAGE :');
              supplierBloc.receiveOfferMessage(m, context);
              onOfferMessage(m);
              break;
            case FS_INVOICE_BIDS:
              var m = InvoiceBid.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\n🥦 🥦 🥦 ########## FCM INVOICE_BID MESSAGE :');
              supplierBloc.receiveInvoiceBidMessage(m, context);
              onInvoiceBidMessage(m);
              break;

            case FS_SETTLEMENTS:
              Map map = json.decode(mJSON);
              prettyPrint(map,
                  '\n\n🥦 🥦 🥦 ########## FCM INVESTOR_INVOICE_SETTLEMENT :');
              onInvestorInvoiceSettlement(
                  InvestorInvoiceSettlement.fromJson(map));
              break;
          }
        } catch (e) {
          print(
              '👿 👿 👿 👿 👿 FCM.configureFCM - Houston, we have a problem with null listener somewhere');
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print(' 📭 📭 configureMessaging onLaunch *********** ');
        prettyPrint(message, ' 📭 📭 message delivered on LAUNCH!');
      },
      onResume: (Map<String, dynamic> message) {
        print(' 📭 📭 configureMessaging onResume *********** ');
        prettyPrint(message, ' 📭 📭 message delivered on RESUME!');
      },
    );

    _fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
    _subscribeToFCMTopics();
  }

  _subscribeToFCMTopics() async {
    if (supplier == null) return;
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_DELIVERY_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVOICE_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_OFFERS + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_DELIVERY_NOTES + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVESTOR_INVOICE_SETTLEMENTS + supplier.participantId);
    print(
        '\n\n🎁 🎁 🎁 DashboardState. SUBSCRIBED to topics - 🥬 POs,  🥬D elivery acceptance,  🥬 Invoice acceptance');
  }
  //end of FCM methods ######################

  @override
  void dispose() {
    print(
        '_DashboardState.dispose closing stream: supplierModelBloc.closeStream();');
    animationController.dispose();
    supplierBloc.closeStream();
    super.dispose();
  }

  Future _getCachedPrefs() async {
    supplier = await SharedPrefs.getSupplier();
    user = await SharedPrefs.getUser();
    themeIndex = await SharedPrefs.getThemeIndex();
    _setTheme(themeIndex);
    fullName = user.firstName + ' ' + user.lastName;
    assert(supplier != null);
    name = supplier.name;
    _configureFCM();
    setState(() {});
    //
  }

  _showBottomSheet(InvoiceBid bid) {
    if (_scaffoldKey.currentState == null) return;
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return AnimatedContainer(
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        height: 400.0,
        color: Colors.brown.shade200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Trading Result',
                    style: Styles.purpleBoldMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InvoiceBidCard(
                bid: bid,
              ),
            ),
          ],
        ),
      );
    });
  }

  Invoice lastInvoice;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  double opacity = 1.0;
  String name;
  SupplierApplicationModel appModel;
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
                  name == null ? 'Org' : name,
                  style: Styles.whiteBoldMedium,
                ),
              )
            ],
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

  void _onRefreshPressed() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: '  🏀  🏀  🏀 Loading fresh data',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    await supplierBloc.refreshModel();
    _scaffoldKey.currentState.removeCurrentSnackBar();
    setState(() {});
  }

  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (appModel == null || appModel.supplier == null) {
      appModel = supplierBloc.appModel;
      return Scaffold(
        appBar: AppBar(
          title: Text('☘ Dashboard loading ...'),
        ),
      );
    }
    return StreamBuilder<SupplierApplicationModel>(
      initialData: supplierBloc.appModel,
      stream: supplierBloc.appModelStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            print('☘ ☘ _DashboardState.build ConnectionState.active');
            break;
          case ConnectionState.done:
            break;
          case ConnectionState.waiting:
            break;
          default:
            if (snapshot.hasError) {
              print('_DashboardState.build snapshot has error');
            }
            break;
        }
        appModel = snapshot.data;
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 3.0,
              title: Text(
                '☘Supplier',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              leading: IconButton(
                  icon: Icon(
                    Icons.apps,
                    color: Colors.white,
                  ),
                  onPressed: _toggleTheme),
              bottom: _getBottom(),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.library_books),
                  onPressed: _goToContracts,
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _onRefreshPressed,
                ),
                IconButton(
                  icon: Icon(Icons.help),
                  onPressed: _goToContactUsPage,
                ),
              ],
            ),
            backgroundColor: Colors.brown.shade100,
            body: Stack(
              children: <Widget>[
                Opacity(
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
                Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: _getListView(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BottomNavigationBar(
                onTap: _onNavTap,
                currentIndex: _index,
                iconSize: 20.0,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.boxOpen),
                      title: Text('Offers')),
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.shoppingCart),
                      title: Text('Purchase Orders')),
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.truck),
                      title: Text('Deliveries')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _index = 0;
  Widget _getListView() {
    var tiles = List<ListTile>();
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
    return appModel == null
        ? Container()
        : ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _onInvoiceTapped,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: appModel.invoices == null
                      ? Container()
                      : SummaryCard(
                          totalCount: appModel.invoices.length,
                          totalCountLabel: 'Invoices',
                          totalCountStyle: Styles.pinkBoldMedium,
                          totalValueStyle: Styles.greyLabelMedium,
                          totalValueLabel: 'Invoiced Total',
                          totalValue: appModel.invoices == null
                              ? 0.0
                              : appModel.getTotalInvoiceAmount(),
                          elevation: 8.0,
                          color: Colors.yellow.shade100,
                        ),
                ),
              ),
              GestureDetector(
                onTap: _onOffersTapped,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: appModel == null
                      ? Container()
                      : OfferSummaryCard(
                          appModel: appModel,
                          elevation: 28.0,
                          offerTotalStyle: Styles.blackBoldLarge,
                        ),
                ),
              ),
              tiles == null
                  ? Container()
                  : Column(
                      children: tiles,
                    ),
            ],
          );
  }

  _onOffersTapped() {
    print('_DashboardState._onOffersTapped ...............');
    Navigator.push(
        context,
        SlideRightRoute(
          widget: OfferList(
            model: appModel,
          ),
        ));
  }

  void _goToContactUsPage() {
    print('_MainPageState._goToContactUsPage .... ');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactUs()),
    );
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
    Navigator.push(
      context,
      SlideRightRoute(widget: InvoicesOnOffer(model: appModel)),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      SlideRightRoute(
          widget: PurchaseOrderListPage(
        model: appModel,
      )),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      SlideRightRoute(widget: DeliveryNoteList()),
    );
  }

  @override
  onActionPressed(int action) {
    print(
        '_DashboardState.onActionPressed ..................  action: $action');

    switch (action) {
      case PurchaseOrderConstant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PurchaseOrderListPage()),
        );
        break;
      case DeliveryAcceptanceConstant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeliveryAcceptanceList()),
        );
        break;
      case ChatResponseConstant:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                    chatResponse: _chatResponse,
                  )),
        );
        break;
      case InvoiceAcceptedConstant:
        _startOffer();
        break;
      case CompanySettlementConstant:
        break;
      case InvestorSettlement:
        break;
      case InvoiceBidConstant:
        break;
      case WalletConstant:
        break;
      case GovtSettlement:
        break;
    }
  }

  void _startOffer() async {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoice ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    var inv = await ListAPI.getSupplierInvoiceByNumber(
        invoiceAcceptance.invoiceNumber, supplier.participantId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MakeOfferPage(inv)),
    );
  }

  void _goToContracts() {
    print('_DashboardState._goToContracts .......');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContractList()),
    );
  }

  static const CompanySettlementConstant = 1,
      DeliveryAcceptanceConstant = 2,
      GovtSettlement = 3,
      PurchaseOrderConstant = 4,
      InvoiceBidConstant = 5,
      InvestorSettlement = 6,
      WalletConstant = 7,
      InvoiceAcceptedConstant = 8,
      ChatResponseConstant = 10;

  PurchaseOrder purchaseOrder;
  ChatResponse _chatResponse;
  DeliveryAcceptance deliveryAcceptance;

  InvoiceAcceptance invoiceAcceptance;

  InvoiceBid invoiceBid;
  bool isAddInvoiceAcceptance = false, isAddDeliveryAcceptance = false;

  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance) async {
    deliveryAcceptance = acceptance;
    _showSnack('Delivery Acceptance arrived', Colors.green);

    setState(() {
      messages.add(Message(
          type: Message.GENERAL_MESSAGE,
          message:
              'Delivery Acceptance arrived: ${getFormattedDateShortWithTime('${acceptance.date}', context)} ',
          subTitle: acceptance.customerName));
    });
    await supplierBloc.refreshModel();
  }

  onInvoiceAcceptanceMessage(InvoiceAcceptance acceptance) async {
    invoiceAcceptance = acceptance;
    _showSnack('Invoice Acceptance arrived', Colors.yellow);
    setState(() {
      messages.add(Message(
        type: Message.GENERAL_MESSAGE,
        message:
            'Invoice Acceptance arrived: ${getFormattedDateShortWithTime('${acceptance.date}', context)} ',
        subTitle: acceptance.customerName,
      ));
    });
    await supplierBloc.refreshModel();
  }

  bool isAddInvoiceBid = false;

  onInvoiceBidMessage(InvoiceBid invoiceBid) async {
    this.invoiceBid = invoiceBid;
    print(
        '\n\n\n_DashboardState.onInvoiceBidMessage ################ INVOICE BID incoming! ${invoiceBid.investorName}');
    _showBottomSheet(invoiceBid);
    setState(() {
      messages.add(Message(
          type: Message.GENERAL_MESSAGE,
          message:
              'Invoice Bid arrived: ${getFormattedAmount('${invoiceBid.amount}', context)} '
              'on ${getFormattedDateShortWithTime(invoiceBid.date, context)}',
          subTitle: invoiceBid.investorName));
    });
    await supplierBloc.refreshModel();
  }

  bool isAddPurchaseOrder = false;

  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) async {
    _showSnack('Purchase Order arrived', Colors.lime);
    this.purchaseOrder = purchaseOrder;
    setState(() {
      messages.add(Message(
          type: Message.PURCHASE_ORDER,
          message:
              'Purchase order arrived: ${getFormattedDateShortWithTime(DateTime.now().toIso8601String(), context)} ${getFormattedAmount('${purchaseOrder.amount}', context)}',
          subTitle: purchaseOrder.purchaserName));
    });
    await supplierBloc.refreshModel();
  }

  onGeneralMessage(Map map) async {
    _showSnack(map['message'], Colors.white);
    setState(() {
      messages.add(Message(
        type: Message.GENERAL_MESSAGE,
        message: map['message'],
      ));
    });
    await supplierBloc.refreshModel();
  }

  void _showSnack(String message, Color color) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: color,
        backgroundColor: Colors.black);
  }

  List<Message> messages = List();
  int themeIndex = 0;

  void _onNavTap(int value) {
    print('_DashboardState._onNavTap ########################## $value');
    _index = value;
    switch (value) {
      case 0:
        _onOffersTapped();
        break;
      case 1:
        _onPurchaseOrdersTapped();
        break;
      case 2:
        _onDeliveryNotesTapped();
        break;
    }
    setState(() {});
  }

  void _toggleTheme() {
    print('🥬 🥬 🥬  _toggleTheme, changeToRandomTheme 🌸 🌸 🌸');
    themeBloc.changeToRandomTheme();
  }

  void _setTheme(int index) {
    print('🥬 🥬 🥬  _setTheme, index: $index');
    themeBloc.changeToTheme(index);
  }

  void onInvestorInvoiceSettlement(
      InvestorInvoiceSettlement investorInvoiceSettlement) async {
    setState(() {
      messages.add(Message(
          type: Message.SETTLEMENT,
          message:
              'Invoice Settlement arrived: ${getFormattedDateShortWithTime('${investorInvoiceSettlement.date}', context)} ',
          subTitle: investorInvoiceSettlement.customerName));
    });
    await supplierBloc.refreshModel();
  }

  void onDeliveryNoteMessage(DeliveryNote m) async {
    setState(() {
      messages.add(Message(
          type: Message.DELIVERY_NOTE,
          message:
              'Delivery Note arrived: ${getFormattedDateShortWithTime('${m.date}', context)} ',
          subTitle: m.customerName));
    });
    await supplierBloc.refreshModel();
  }

  void onOfferMessage(Offer offer) async {
    setState(() {
      messages.add(Message(
          type: Message.OFFER,
          message:
              'Offer arrived: ${getFormattedDateShortWithTime('${offer.date}', context)} ',
          subTitle: offer.customerName));
    });
    await supplierBloc.refreshModel();
  }

  void onInvoiceMessage(Invoice invoice) async {
    setState(() {
      messages.add(Message(
          type: Message.INVOICE,
          message:
              'Invoice arrived: ${getFormattedDateShortWithTime('${invoice.date}', context)} ',
          subTitle: invoice.customerName));
    });
    await supplierBloc.refreshModel();
  }

  void onChatResponseMessage(ChatResponse m) {
    prettyPrint(
        m.toJson(), '_DashboardState.onChatResponseMessage ...........');
    chatBloc.receiveChatResponse(m);
    _chatResponse = m;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: m.responseMessage,
        textColor: Styles.white,
        backgroundColor: Styles.black,
        actionLabel: 'Reply',
        listener: this,
        icon: Icons.chat,
        action: ChatResponseConstant);
  }
}

class OfferSummaryCard extends StatelessWidget {
  final SupplierApplicationModel appModel;
  final double elevation;
  final TextStyle offerTotalStyle;
  final Color color;
  OfferSummaryCard(
      {this.appModel, this.elevation, this.offerTotalStyle, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 16.0 : elevation,
      color: color == null ? Theme.of(context).cardColor : color,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Invoice Offers',
                    style: Styles.greyLabelMedium,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80.0,
                  child: Text(
                    'Open Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${appModel.getTotalOpenOffers()}',
                    style: Styles.blackBoldMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Offer Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${getFormattedAmount('${appModel.getTotalOpenOfferAmount()}', context)}',
                      style: offerTotalStyle == null
                          ? Styles.tealBoldMedium
                          : offerTotalStyle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Offer Settlements',
                    style: Styles.greyLabelMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text(
                      'Settlements',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      appModel.settlements == null
                          ? '0'
                          : '${appModel.settlements.length}',
                      style: Styles.tealBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text(
                      'Settled Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${getFormattedAmount('${appModel.getTotalSettlementAmount()}', context)}',
                      style: Styles.tealBoldLarge,
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
