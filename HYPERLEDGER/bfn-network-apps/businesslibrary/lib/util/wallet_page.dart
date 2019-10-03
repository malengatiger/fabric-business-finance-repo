import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/stellar/Account.dart';
import 'package:businesslibrary/stellar/Balance.dart';
import 'package:businesslibrary/util/comms.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  final String name, participantId;
  final int type;

  WalletPage(
      {@required this.name, @required this.participantId, @required this.type});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String name, participantId;
  int type;
  Wallet wallet;
  Account account;

  @override
  void initState() {
    super.initState();
    _checkWallet();
  }

  @override
  Widget build(BuildContext context) {
    name = widget.name;
    participantId = widget.participantId;
    type = widget.type;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('BFN Blockchain Wallet'),
        elevation: 8.0,
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: <Widget>[
                  Text(
                    wallet == null ? ' n/a ' : wallet.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 22.0),
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(80.0)),
      ),
      body: _getBody(),
      backgroundColor: Colors.brown.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: _getAccount,
        elevation: 16.0,
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  Future _getAccount() async {
    print('_WalletPageState._getAccount .......... ${wallet.stellarPublicKey}');

//    AppSnackbar.showSnackbarWithProgressIndicator(
//        scaffoldKey: _scaffoldKey,
//        message: 'Getting Balances ...',
//        textColor: Colors.white,
//        backgroundColor: Colors.black);

    account = await StellarCommsUtil.getAccount(wallet.stellarPublicKey);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    setState(() {});
    return account;
  }

  void _checkWallet() async {
    wallet = await SharedPrefs.getWallet();

    if (wallet == null) {
      _showDialog();
    } else {
      account = await SharedPrefs.getAccount();
      //get latest balances
      await _getAccount();
      setState(() {});
    }
  }

  Future _createWallet() async {}

  @override
  onActionPressed(int action) {
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
  }

  Widget _getBody() {
    if (account == null) {
      return Container();
    }
    List<Widget> widgets = List();
    widgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            'Balances',
            style: TextStyle(
                fontSize: 28.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));

    Balance bb = new Balance('245000.000', 'BFN');
    bb.asset_type = 'BFN';
    bb.balance = '250000.0000';
    //todo - only for testing
    if (isInDebugMode && account.balances.length == 1) {
      account.balances.add(bb);
    }
    account.balances.forEach((bal) {
      widgets.add(BalanceCard(bal, context));
    });
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 40.0, bottom: 20.0),
          child: Row(
            children: <Widget>[
              Text(
                'Registered:',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _getDate(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: widgets,
          ),
        ),
      ],
    );
  }

  String _getDate() {
    if (wallet.dateRegistered == null) {
      return '';
    }
    return getFormattedDate(wallet.dateRegistered);
  }

  void _showDialog() {
    print('_WalletPageState._showDialog --- ');
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Create Wallet",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                          'Do you want to create a new BFN Wallet?\nYou need te wallet to move value across the network'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'NO',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    onPressed: _createWallet,
                    elevation: 4.0,
                    color: Colors.teal.shade400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Create Wallet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }
}

class BalanceCard extends StatelessWidget {
  final Balance balance;
  final BuildContext context;
  BalanceCard(this.balance, this.context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        color: Colors.lime.shade50,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 20.0, bottom: 20.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Icon(
                  Icons.apps,
                  color: Theme.of(context).accentColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  getBalance(),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _getCurrency(),
                  style: TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrency() {
    if (balance.asset_type == 'native') {
      return 'XLM';
    } else {
      return balance.asset_type;
    }
  }

  String getBalance() {
    var balx = getFormattedAmount(balance.balance, context);
    return balx;
  }
}
