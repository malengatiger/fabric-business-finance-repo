import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportEmail extends StatefulWidget {
  final String userType;

  SupportEmail(this.userType);

  @override
  _SupportEmailState createState() => _SupportEmailState();
}

class _SupportEmailState extends State<SupportEmail> {
  static const String USER_SUPPLIER = '1',
      USER_INVESTOR = '2',
      USER_CUSTOMER = '3';

  Investor investor;
  Supplier supplier;
  Customer customer;
  User user;
  String subject, text;

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    switch (widget.userType) {
      case USER_CUSTOMER:
        customer = await SharedPrefs.getCustomer();
        break;
      case USER_INVESTOR:
        investor = await SharedPrefs.getInvestor();
        break;
      case USER_SUPPLIER:
        supplier = await SharedPrefs.getSupplier();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = 'General Support';
    switch (widget.userType) {
      case USER_CUSTOMER:
        title = 'Customer Support';
        break;
      case USER_INVESTOR:
        title = 'Investor Support';
        break;
      case USER_SUPPLIER:
        title = 'Supplier Support';
        break;
    }
    print('_SupportEmailState.build title: $title');
    Widget _getBottom() {
      return PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'One of our support representative will respond as soon as possible after receiving your email.\n\nThank you for getting in touch!',
                  style: Styles.whiteSmall,
                )),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: _getBottom(),
      ),
      backgroundColor: Colors.brown.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Pick Message Type',
                    style: Styles.greyLabelMedium,
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Card(
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    offerIssue,
                    style: Styles.blackBoldSmall,
                  ),
                  leading: Icon(Icons.access_alarm, color: getRandomColor()),
                  onTap: () {
                    print('_SupportEmailState.build -- tapped $offerIssue');
                    subject = offerIssue;
                    _startDefaultEmailApp();
                  },
                ),
              ),
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text(
                    settlementIssue,
                    style: Styles.blackBoldSmall,
                  ),
                  leading: Icon(Icons.attach_money, color: getRandomColor()),
                  onTap: () {
                    print(
                        '_SupportEmailState.build -- tapped $settlementIssue');
                    subject = settlementIssue;
                    _startDefaultEmailApp();
                  },
                ),
              ),
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text(
                    purchaseOrderIssue,
                    style: Styles.blackBoldSmall,
                  ),
                  leading: Icon(Icons.assignment, color: getRandomColor()),
                  onTap: () {
                    print(
                        '_SupportEmailState.build -- tapped $purchaseOrderIssue');
                    subject = purchaseOrderIssue;
                    _startDefaultEmailApp();
                  },
                ),
              ),
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text(
                    deliveryNoteIssue,
                    style: Styles.blackBoldSmall,
                  ),
                  leading: Icon(Icons.add_alert, color: getRandomColor()),
                  onTap: () {
                    print(
                        '_SupportEmailState.build -- tapped $deliveryNoteIssue');
                    subject = deliveryNoteIssue;
                    _startDefaultEmailApp();
                  },
                ),
              ),
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text(
                    messageIssue,
                    style: Styles.blackBoldSmall,
                  ),
                  leading: Icon(Icons.chat, color: getRandomColor()),
                  onTap: () {
                    print('_SupportEmailState.build -- tapped $messageIssue');
                    subject = messageIssue;
                    _startDefaultEmailApp();
                  },
                ),
              ),
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text(
                    generalIssue,
                    style: Styles.blackBoldSmall,
                  ),
                  leading: Icon(Icons.subject, color: getRandomColor()),
                  onTap: () {
                    print('_SupportEmailState.build -- tapped $generalIssue');
                    subject = generalIssue;
                    _startDefaultEmailApp();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const myEmail = 'aubrey@aftarobot.com';
  static const offerIssue = 'Issue with Offers',
      settlementIssue = 'Issue with Settlement',
      registrationIssue = 'Issue with Registration',
      signInIssue = 'Problem Signing In',
      purchaseOrderIssue = 'Problem with Purchase Order',
      deliveryNoteIssue = 'Problem with to Delivery Note',
      messageIssue = 'Cannot receive messages',
      generalIssue = 'General Anything';

  void _startDefaultEmailApp() async {
    var mUrl = 'mailto:$myEmail?subject=$subject';
    var encoded = Uri.encodeFull(mUrl);
    var decoded = Uri.decodeFull(encoded);
    assert(mUrl == decoded);
    print('_SupportEmailState._sendEmail uri: $mUrl');
    print('_SupportEmailState._sendEmail encoded: $encoded');
    try {
      if (await canLaunch(encoded)) {
        Navigator.pop(context);
        await launch(encoded);
      } else {
        throw 'Could not launch $encoded';
      }
    } catch (e) {
      print(
          '\n\n_SupportEmailState._startDefaultEmailApp ERROR ERROR ERROR ERROR');
      print(e);
    }
  }
}
