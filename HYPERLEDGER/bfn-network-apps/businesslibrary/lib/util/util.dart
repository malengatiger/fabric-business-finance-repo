import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

//const DEBUG_URL_HOME = 'https://bfnrestv3.eu-gb.mybluemix.net/api/'; //FIBRE
//const DEBUG_URL_ROUTER = 'https://bfnrestv3.eu-gb.mybluemix.net/api/'; //ROUTER
const RELEASE_URL = 'https://bfnrestv3.eu-gb.mybluemix.net/api/'; //CLOUD
const DEBUG_URL = 'https://192.168.86.239:3001/sendTransaction'; //FIBRE

//const DEBUG_URL_WEB_API_SENDTX = 'http://192.168.86.239:3000/sendTransaction';
//const RELEASE_URL_WEB_API_SENDTX =
//    'https://bfnwebapi1.eu-gb.mybluemix.net/sendTransaction';
//
//const DEBUG_URL_WEB_API_SENDTXS = 'http://192.168.86.239:3000/sendTransactions';
//const RELEASE_URL_WEB_API_SENDTXS =
//    'https://bfnwebapi1.eu-gb.mybluemix.net/sendTransactions';

const DEBUG_URL_WEB_API = 'http://192.168.86.239:3001/';
//const DEBUG_URL_WEB_API = 'http://192.168.86.239:3001/';

const RELEASE_URL_WEB_API = 'https://bfnwebapi.mybluemix.net/';
//https://bfnwebapi-ztpzdxn4iq-uc.a.run.app/ping
//https://bfnwebapi.mybluemix.net/executeAutoTrades

const DEBUG_URL_WEB_API_SENDTX = 'http://192.168.86.239:3001/sendTransaction';
const RELEASE_URL_WEB_API_SENDTX =
    'https://bfnwebapi-ztpzdxn4iq-uc.a.run.app/sendTransaction';

const DEBUG_URL_WEB_API_SENDTXS = 'http://192.168.86.239:3001/sendTransactions';
const RELEASE_URL_WEB_API_SENDTXS =
    'https://bfnwebapi.mybluemix.net/sendTransactions';
////const RELEASE_URL_WEB_API_SENDTXS =
//    'https://bfnwebapi-ztpzdxn4iq-uc.a.run.app/sendTransactions';

String getURL() {
  var url;
  if (isInDebugMode) {
    url = DEBUG_URL; //switch  to DEBUG_URL_ROUTER before demo
  } else {
    url = RELEASE_URL;
  }
  return url;
}

String getChaincodeUrl() {
  if (isInDebugMode) {
    return DEBUG_URL_WEB_API_SENDTX;
  } else {
    return DEBUG_URL_WEB_API_SENDTX;
  }
}

String getMultipleTransactionsUrl() {
  var url;
  if (isInDebugMode) {
    url = DEBUG_URL_WEB_API_SENDTXS;
  } else {
    url = DEBUG_URL_WEB_API_SENDTXS;
  }
  return url;
}

String getWebUrl() {
  var url;
  //todo - fix this before production .... 🌼 🌺🌼 🌺 🌼 🌺🌼 🌺 🌼 🌺
  if (isInDebugMode) {
    url = DEBUG_URL_WEB_API;
  } else {
    url = RELEASE_URL_WEB_API;
  }
  return url;
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

TextStyle getTitleTextWhite() {
  return TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );
}

TextStyle getTextWhiteMedium() {
  return TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
}

TextStyle getTextWhiteSmall() {
  return TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );
}

List<DropdownMenuItem<int>> _items = List();
var bold = TextStyle(fontWeight: FontWeight.bold);
List<DropdownMenuItem<int>> buildDaysDropDownItems() {
  var item1 = DropdownMenuItem<int>(
    value: 7,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.pink,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '7 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item1);
  var item2 = DropdownMenuItem<int>(
    value: 14,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.teal,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '14 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item2);

  var item3 = DropdownMenuItem<int>(
    value: 30,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.brown,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '30 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item3);
  var item4 = DropdownMenuItem<int>(
    value: 60,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.purple,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '60 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item4);
  var item5 = DropdownMenuItem<int>(
    value: 90,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.deepOrange,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '90 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item5);

  var item6 = DropdownMenuItem<int>(
    value: 120,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.blue,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '120 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item6);
  var item7 = DropdownMenuItem<int>(
    value: 365,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '365 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item7);

  return _items;
}

String _toTwoDigitString(int value) {
  return value.toString().padLeft(2, '0');
}

void listen() {
  CollectionReference reference = Firestore.instance.collection('planets');
  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      // Do something with change
    });
  });
}

final channel =
    new IOWebSocketChannel.connect("ws://bfnrestv3.eu-gb.mybluemix.net");
void listenToWebSocket() async {
  //channel.sink.add("connected!");
  print(
      'listenToWebSocket ------- starting  #################################');
  channel.stream.listen((message) {
    print('listenToWebSocket ###################: ' + message);
  });
}

/*
{"$class":"com.oneconnect.biz.ExecuteInvestorAutoTradesEvent","session":{"$class":"com.oneconnect.biz.InvestorAutoTradeSession","sessionId":"4822eae0-9620-11e8-cfb3-f1822a307d2e","date":"2018-09-08T19:42:14.616Z","sessionBids":0,"sessionTotal":0,"maxSessionInvestment":12500000,"order":"resource:com.oneconnect.biz.AutoTradeOrder#a4e04a10-9620-11e8-8d4d-bd99de9308a9","profile":"resource:com.oneconnect.biz.InvestorProfile#924a7240-9620-11e8-9eea-65183e9eec26","bids":[],"offers":[]},"eventId":"d3e1f09bdac7f11de97bd06a6dde3d1c6389c3eb5210545d1989790c9817a7d4#0","timestamp":"2018-09-08T19:42:14.288Z"}
I/flutter (21367): listenForExecuteInvestorAutoTradesEvent ERROR NoSuchMethodError: The method 'forEach' was called on null.
 */
