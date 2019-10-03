import 'package:businesslibrary/util/selectors.dart';
import 'package:flutter/material.dart';

class Message {
  int type;
  String message, subTitle;
  Icon icon;

  Message({@required this.type, @required this.message, this.subTitle}) {
    switch(type) {
      case PURCHASE_ORDER:
        icon = Icon(Icons.shopping_cart, color: Colors.black);
        break;
      case DELIVERY_ACCEPTANCE:
        icon = Icon(Icons.shop, color: Colors.pink);
        break;
      case INVOICE_ACCEPTANCE:
        icon = Icon(Icons.done, color: Colors.blue);
        break;
      case GENERAL_MESSAGE:
        icon = Icon(Icons.add_alert, color: Colors.black);
        break;
      case INVOICE_BID:
        icon = Icon(Icons.assessment, color: getRandomColor(),);
        break;
      case INVOICE:
        icon = Icon(Icons.airport_shuttle, color: Colors.purple,);
        break;
      case DELIVERY_NOTE:
        icon = Icon(Icons.cake, color: Colors.black,);
        break;
      case OFFER:
        icon = Icon(Icons.alarm, color: Colors.brown.shade600,);
        break;
      case SETTLEMENT:
        icon = Icon(Icons.attach_money, color: Colors.teal.shade900,);
        break;
    }
  }

  static const int PURCHASE_ORDER = 1,
      DELIVERY_ACCEPTANCE = 2,
      INVOICE_ACCEPTANCE = 3,
      INVOICE_BID = 4,
      SETTLEMENT = 5,
      GENERAL_MESSAGE = 6, OFFER = 7, DELIVERY_NOTE = 8, INVOICE = 9;
}
