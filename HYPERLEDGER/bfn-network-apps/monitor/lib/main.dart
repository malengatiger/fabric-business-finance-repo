import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/chat_bloc.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/support/chat_response_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:monitor/ui/theme_util.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: getTheme(),
//      home: new MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/': (_) => MyHomePage(),
        '/webview': (_) => WebviewScaffold(
              url: 'https://www.youtube.com/',
              appBar: AppBar(title: Text('YouTube')),
              withJavascript: true,
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements SnackBarListener {
  static const NUMBER_OF_BIDS_TO_MAKE = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  List<AutoTradeOrder> _orders;
  List<InvestorProfile> _profiles;
  DateTime startDate;
  OpenOfferSummary summary = OpenOfferSummary(
      offers: List(),
      totalOfferAmount: 0.0,
      totalOpenOffers: 0,
      startedAfter: 0);
  String webViewTitle, webViewUrl;
  AutoTradeStart autoTradeStart = AutoTradeStart();

  //FCM methods #############################
  _configureFCM() async {
    print(
        '\n\n\# 🔵  🔵 ############### CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');

    bool isRunningIOS = await isDeviceIOS();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n ✅ ################ Message from FCM ################# ${DateTime.now().toIso8601String()}');

        String messageType = 'unknown';
        String mJSON;
        try {
          if (isRunningIOS == true) {
            messageType = map["messageType"];
            mJSON = map['json'];
            print('FCM.configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('FCM.configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print(
              'FCM.configureFCM -------- EXCEPTION handling platform detection');
        }

        print(
            'FCM.configureFCM ************************** messageType: $messageType');

        try {
          switch (messageType) {
            case 'CHAT_MESSAGE':
              var m = ChatMessage.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), '\n\n########## FCM CHAT MESSAGE :');
              onChatMessage(m);
              break;
            case 'OFFER':
              var m = Offer.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), '\n\n########## FCM OFFER MESSAGE :');
              onOfferMessage(m);
              break;
            case 'INVOICE_BID':
              var m = InvoiceBid.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM INVOICE_BID MESSAGE :');
              onInvoiceBidMessage(m);
              break;

            case 'HEARTBEAT':
              Map map = json.decode(mJSON);
              prettyPrint(map, '\n\n########## FCM HEARTBEAT :');
              onHeartbeat(map);
              break;
          }
        } catch (e) {
          print(
              'FCM.configureFCM - Houston, we have a problem with null listener somewhere');
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print('configureMessaging onLaunch *********** ');
        prettyPrint(message, 'message delivered on LAUNCH!');
      },
      onResume: (Map<String, dynamic> message) {
        print('configureMessaging onResume *********** ');
        prettyPrint(message, 'message delivered on RESUME!');
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});

    _subscribeToFCMTopics();
  }

  _subscribeToFCMTopics() async {
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_OFFERS);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_HEARTBEATS);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_CHAT_MESSAGES_ADDED);
    print(
        '\n\n_DashboardState._subscribeToFCMTopics SUBSCRIBED to topis - Bids, Offers, heartbeat and General');
  }

  //end of FCM methods ######################

  void onChatMessage(ChatMessage msg) {
    print('_MyHomePageState.onChatMessage ........... .................');
    prettyPrint(msg.toJson(), '##### process this message just arrived:');
    this.chatMessage = msg;
    chatBloc.receiveChatMessage(msg);

    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: msg.message,
        textColor: Styles.white,
        backgroundColor: Styles.black,
        actionLabel: 'Reply',
        listener: this,
        icon: Icons.chat,
        action: 3);
  }

  @override
  void initState() {
    super.initState();

    _configureFCM();
    _getLists(true);
  }

  int minutes = 120;

  _getMinutes() async {
    minutes = await SharedPrefs.getMinutes();
    if (minutes == null || minutes == 0) {
      minutes = 9999;
    }
    controller.text = '$minutes';
    setState(() {});
  }

  _getLists(bool showSnack) async {
    if (showSnack == true) {
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Loading data for trades ...',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }

    autoTradeStart = await SharedPrefs.getAutoTradeStart();
    if (autoTradeStart == null) {
      autoTradeStart = AutoTradeStart(
          elapsedSeconds: 0.0,
          dateEnded: getUTC(DateTime.now()),
          possibleAmount: 0.0,
          totalAmount: 0.0,
          totalOffers: 0,
          totalValidBids: 0);
    }
    await _getMinutes();
    setState(() {});

    _orders = await ListAPI.getAutoTradeOrders();
    setState(() {});
    _profiles = await ListAPI.getInvestorProfiles();
    //summary = await ListAPI.getOpenOffersSummary();

    setState(() {});
    _scaffoldKey.currentState.hideCurrentSnackBar();

    opacity = 1.0;
    if (_orders.isNotEmpty && _profiles.isNotEmpty) {
      _start();
    } else {
      print('_MyHomePageState._getLists ------- No orders to process');
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No orders to process',
          textColor: Styles.lightBlue,
          backgroundColor: Styles.black);
    }
  }

  Timer timer;

  ///start periodic timer to control AutoTradeExecutionBuilder
  _start() async {
    print(
        '_MyHomePageState._start ..... Timer.periodic(Duration((minutes: $minutes) time: ${DateTime.now().toIso8601String()}');
    if (timer != null) {
      if (timer.isActive) {
        timer.cancel();
        print(
            '_MyHomePageState._start -------- TIMER cancelled. timer.tick: ${timer.tick}');
      }
    }
    try {
      timer = Timer.periodic(Duration(minutes: minutes), (mTimer) async {
        print(
            '_MyHomePageState._start:\n\n\n TIMER tripping - starting AUTO TRADE cycle .......time: '
            '${DateTime.now().toIso8601String()}.  mTimer.tick: ${mTimer.tick}...\n\n');
        summary = await ListAPI.getOpenOffersSummary();
        if (summary.totalOpenOffers == null) {
          summary.totalOpenOffers = 0;
        }

        if (summary.totalOpenOffers > 0) {
          setState(() {
            _showProgress = true;
            autoTradeStart = AutoTradeStart();
            bidsArrived.clear();
          });
          setState(() {
            messages.clear();
            opacity = 0.0;
          });
          startDate = DateTime.now();
          autoTradeStart = await DataAPI3.executeAutoTrades();

          prettyPrint(
              autoTradeStart.toJson(), '\n\n####### RESULT from AutoTrades:');
          if (autoTradeStart == null) {
            setState(() {
              messages.add('Problem with Auto Trade Session');
            });
            AppSnackbar.showErrorSnackbar(
                scaffoldKey: _scaffoldKey,
                message: 'Problem with Auto Trade Session',
                listener: this,
                actionLabel: 'close');
          } else {
            setState(() {
              _showProgress = null;
            });
            prettyPrint(
                autoTradeStart.toJson(), '##### AutoTradeStart from Firestore');
            AppSnackbar.showSnackbar(
                scaffoldKey: _scaffoldKey,
                message: 'Auto Trade Session complete',
                textColor: Styles.white,
                backgroundColor: Styles.teal);
            _getLists(true);
          }
        } else {
          print('_MyHomePageState._start ***************'
              ' No open offers available. Will try again in $minutes minutes');
          AppSnackbar.showSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'No open offers in network',
              textColor: Styles.lightBlue,
              backgroundColor: Styles.black);
          return;
        }
      });
    } catch (e) {
      setState(() {
        messages.add('Problem with Auto Trade Session\n$e');
      });
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Problem with Auto Trade Session',
          listener: this,
          actionLabel: 'close');
    }
  }

  List<InvoiceBid> bids = List();

  String time, count, amount;
  double opacity = 1.0;
  double opacity2 = 0.0;

  void summarize() {
    double t = 0.00;
    bids.forEach((m) {
      t += m.amount;
    });
    amount = '${getFormattedAmount('$t', context)}';
    this.count = '${bids.length}';
    time = getFormattedDateHour(DateTime.now().toIso8601String());
    setState(() {});
  }

  void _restart() async {
    setState(() {
      messages.clear();
    });

    try {
      setState(() {
        _showProgress = true;
        autoTradeStart = AutoTradeStart(
          totalAmount: 0.0,
          possibleAmount: 0.0,
          dateEnded: DateTime.now().toIso8601String(),
          totalValidBids: 0,
          elapsedSeconds: 0,
        );
        bidsArrived.clear();
        opacity = 0.0;
      });
      startDate = DateTime.now();
      var msg = await DataAPI3.executeAutoTrades();
      print('RETURN from api call: $msg');
      setState(() {
        _showProgress = null;
      });
      setState(() {});
      opacity = 1.0;

      print('_MyHomePageState._start ++++ summary in the house!');
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Auto Trade Session started',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      setState(() {});
      //_getLists(false);

    } catch (e) {
      setState(() {
        _showProgress = null;
        messages.add('$e');
      });

      _getLists(false);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Problem with Auto Trade Session',
          listener: this,
          actionLabel: 'close');
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'OneConnect - BFN Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                Opacity(
                  opacity: opacity2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController controller = TextEditingController();
  bool _showProgress;

  _refresh() {
    _getLists(true);
  }

  _goToMessages() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ChatResponsePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 8.0,
        title: Text(
          'BFN Monitor',
          style: Styles.whiteBoldMedium,
        ),
        leading: IconButton(
            icon: Icon(
              Icons.apps,
              color: Colors.white,
            ),
            onPressed: null),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _refresh,
          ),
          IconButton(
            icon: Icon(
              Icons.message,
              color: Colors.white,
            ),
            onPressed: _goToMessages,
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
          _getBody(),
        ],
      ),
    );
  }

  ChatMessage chatMessage;
  @override
  onActionPressed(int action) {
    switch (action) {
      case 3:
        AssertionError(chatMessage != null);
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ChatResponsePage(
                    chatMessage: chatMessage,
                  )),
        );
        break;
    }
  }

  void _onMinutesChanged(String value) {
    minutes = int.parse(value);
    if (minutes == 0) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Zero is not valid for trade frequency',
          listener: this,
          actionLabel: 'close');
      return;
    }
    SharedPrefs.saveMinutes(minutes);
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Trading Timer set to $minutes minutes',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    _start();
  }

  void _onSessionTapped() {
//    if (bids.isEmpty && invalidUnits.isEmpty) {
//      AppSnackbar.showErrorSnackbar(
//          scaffoldKey: _scaffoldKey,
//          message: 'No session details available',
//          listener: this,
//          actionLabel: 'OK');
//      return;
//    }
//    Navigator.push(
//      context,
//      new MaterialPageRoute(
//          builder: (context) => new JournalPage(
//                bids: bids,
//                units: invalidUnits,
//              )),
//    );
  }

  Widget _getBody() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
          child: Card(
            elevation: 2.0,
            color: Colors.orange.shade50,
            child: Column(
              children: <Widget>[
                _getSubHeader(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: <Widget>[
                      _getAutoTraderView(),
                      _getOfferAmountView(),
                    ],
                  ),
                ),
                _getOfferAmount(),
              ],
            ),
          ),
        ),
        _getSessionCard(),
        _getSessionLog(),
      ],
    );
  }

  List<String> messages = List();
  Widget _getSessionLog() {
    if (messages.isEmpty) {
      return Container();
    }
    List<Widget> widgets = List();

    messages.forEach((message) {
      TextStyle style = Styles.blackMedium;
      Icon icon = Icon(
        Icons.apps,
        color: getRandomColor(),
      );
      if (message.contains('AutoTrade')) {
        style = Styles.blackBoldMedium;
        icon = Icon(
          Icons.message,
          color: Colors.black,
        );
      }
      if (message.contains('BFN')) {
        style = Styles.blackBoldMedium;
        icon = Icon(
          Icons.timer,
          color: Colors.black,
        );
      }
      if (message.contains('ALLOWABLE')) {
        style = Styles.blueBoldMedium;
        icon = Icon(
          Icons.assignment_turned_in,
          color: Colors.black,
        );
      }
      if (message.contains('completed')) {
        style = Styles.purpleBoldMedium;
        icon = Icon(
          Icons.beenhere,
          color: Colors.purple.shade800,
        );
      }
      if (message.contains('reserved')) {
        style = TextStyle(color: Colors.black, fontSize: 16.0);
        icon = Icon(
          Icons.apps,
          color: getRandomColor(),
        );
      }
      if (message.contains('Matcher')) {
        style = Styles.blackBoldMedium;
        icon = Icon(
          Icons.airport_shuttle,
          color: Colors.black,
        );
      }
      var tile = ListTile(
        title: Text(
          message,
          style: style,
        ),
      );
      widgets.add(tile);
    });
    return Column(
      children: widgets,
    );
  }

  Widget _getSessionCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: GestureDetector(
        onTap: _onSessionTapped,
        child: Card(
          elevation: 8.0,
          color: Colors.purple.shade50,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 20.0, right: 20.0, bottom: 20.0),
            child: Column(
              children: <Widget>[
                _getHeader(),
                _getTime(),
                _getAmount(),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _getTrades(),
                ),
                _getPossible(),
                _getElapsed(),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: Duration(microseconds: 2000),
                    child: RaisedButton(
                      color: Colors.purple.shade500,
                      elevation: 8.0,
                      onPressed: _restart,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Start Invoice Auto Trading',
                          style: Styles.whiteSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSubHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Automatic Trade every',
                  style: Styles.greyLabelMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60.0, right: 100.0),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(),
              onChanged: _onMinutesChanged,
              maxLength: 4,
              style: Styles.blackBoldMedium,
              decoration: InputDecoration(
                labelText: 'Minutes',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAutoTraderView() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Traders',
              style: Styles.greyLabelSmall,
            ),
          ),
          Text(
            _orders == null ? '0' : '${_orders.length}',
            style: Styles.pinkBoldMedium,
          ),
        ],
      ),
    );
  }

  Widget _getOfferAmountView() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Open Offers',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              summary == null
                  ? '0'
                  : getFormattedNumber(summary.totalOpenOffers, context),
              style: Styles.blueBoldLarge,
            ),
          ),
        ],
      ),
    );
  }

  double width = 80.0;
  Widget _getOfferAmount() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 20.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Amount',
              style: Styles.greyLabelSmall,
            ),
          ),
          Text(
            summary == null
                ? '0.00'
                : '${getFormattedAmount('${summary.totalOfferAmount}', context)}',
            style: Styles.blackBoldLarge,
          ),
        ],
      ),
    );
  }

  Widget _getHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Text(
            _showProgress == true ? '' : 'Auto Trading Session',
            style: Styles.greyLabelMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  _showProgress == null ? '' : 'Auto Trade running ...',
                  style: Styles.blueBoldSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Container(
                    width: 16.0,
                    height: 16.0,
                    child: _showProgress == null
                        ? Container()
                        : CircularProgressIndicator(
                            strokeWidth: 4.0,
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTime() {
    return Row(
      children: <Widget>[
        Container(
          width: width,
          child: Text(
            'Time: ',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Row(
            children: <Widget>[
              _getDate(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  autoTradeStart == null
                      ? '00:00'
                      : getFormattedDateHour(
                          _formatDate(autoTradeStart.dateEnded)),
                  style: Styles.blackSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    if (date == null) return '';
    try {
      var dt = DateTime.parse(date).toLocal().toIso8601String();
      return dt;
    } catch (e) {
      return '';
    }
  }

  Widget _getDate() {
    if (autoTradeStart == null) {
      return _getNow();
    }
    if (autoTradeStart.dateEnded == null) {
      return _getNow();
    } else {
      try {
        String date = DateTime.parse(autoTradeStart.dateEnded)
            .toLocal()
            .toIso8601String();
        return Text(
          getFormattedDateShort('$date', context),
          style: Styles.blackSmall,
        );
      } catch (e) {
        return _getNow();
      }
    }
  }

  Text _getNow() {
    return Text(
      getFormattedDateShort('${DateTime.now().toIso8601String()}', context),
      style: Styles.blackSmall,
    );
  }

  Widget _getAmount() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Amount:',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart == null
                  ? '0.00'
                  : getFormattedAmount(
                      '${autoTradeStart.totalAmount}', context),
              style: Styles.tealBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTrades() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Trades: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart == null ? '0' : '${autoTradeStart.totalValidBids}',
              style: Styles.blackBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPossible() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Possible: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart == null
                  ? '0.00'
                  : getFormattedAmount(
                      '${autoTradeStart.possibleAmount}', context),
              style: Styles.blackSmall,
            ),
          ),
        ],
      ),
    );
  }

  String translateTime() {
    if (autoTradeStart == null) {
      return '0 seconds';
    }
    if (autoTradeStart.elapsedSeconds == null) {
      return '0 seconds';
    }
    if (autoTradeStart.elapsedSeconds < 60) {
      return '${autoTradeStart.elapsedSeconds} seconds';
    }
    var min = autoTradeStart.elapsedSeconds ~/ 60;
    var rem = autoTradeStart.elapsedSeconds % 60;
    if (rem > 0) {
      min++;
      return '$min minutes ${rem.toStringAsFixed(0)} seconds';
    } else {
      return '$min minutes';
    }
  }

  Widget _getElapsed() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              'Elapsed: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart == null ? '0.0' : translateTime(),
              style: Styles.blueSmall,
            ),
          ),
        ],
      ),
    );
  }

  List<InvoiceBid> bidsArrived = List();
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print(
        '_MyHomePageState.onInvoiceBidMessage ############# INVOICE BID arrived: ${invoiceBid.amount} ${invoiceBid.investorName}');
    var msg =
        '${invoiceBid.investorName} bid ${getFormattedAmount('${invoiceBid.amount}', context)} '
        ', reserved: ${invoiceBid.reservePercent} % at: ${getFormattedDateHour(DateTime.now().toIso8601String())}';
    bidsArrived.add(invoiceBid);
    var tot = 0.00;
    bidsArrived.forEach((bid) {
      tot += bid.amount;
    });

    if (autoTradeStart == null) {
      autoTradeStart = AutoTradeStart();
    }
    autoTradeStart.totalAmount = tot;
    autoTradeStart.totalValidBids = bidsArrived.length;
    autoTradeStart.dateEnded = DateTime.now().toIso8601String();
    autoTradeStart.elapsedSeconds =
        DateTime.now().difference(startDate).inSeconds * 1.0;
    autoTradeStart.dateEnded =
        getFormattedDateHour('${DateTime.now().toIso8601String()}');
    summary.totalOpenOffers--;
    summary.totalOfferAmount -= invoiceBid.amount;
    //_getLists(false);
    setState(() {
      messages.add(msg);
    });
    print(msg);
    print(
        '\n_MyHomePageState.onInvoiceBidMessage ... bids arrived: ${bidsArrived.length}\n\n');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: msg,
        textColor: Styles.white,
        backgroundColor: Styles.teal);
  }

  onOfferMessage(Offer offer) {
    print('_MyHomePageState.onOfferMessage');
    prettyPrint(offer.toJson(), 'OFFER arrived via FCM');
  }

  onHeartbeat(Map map) {
    print('\n\n_MyHomePageState.onHeartbeat ############ map: $map');
    print('_MyHomePageState.onHeartbeat updating messages');
    setState(() {
      messages.add(map['message']);
    });
  }
}
