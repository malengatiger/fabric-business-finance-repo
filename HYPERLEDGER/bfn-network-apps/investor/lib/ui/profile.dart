import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:investor/bloc/bloc.dart';
import 'package:investor/ui/sector_list_page.dart';
import 'package:investor/ui/supplier_list_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  InvestorProfile profile;
  AutoTradeOrder order;
  Investor investor;
  List<Supplier> suppliers;
  List<Sector> sectors;

  @override
  initState() {
    super.initState();
    _getCachedData();
    _setItems();
  }

  int numberOfSuppliers = 0, numberOfSectors = 0;
  void _getCachedData() async {
    print('_ProfilePageState._getCachedData ................................');
    investor = await SharedPrefs.getInvestor();
    autoTradeOrder = await SharedPrefs.getAutoTradeOrder();
    assert(investor != null);
    setState(() {});
    profile = await SharedPrefs.getInvestorProfile();
    if (profile == null || autoTradeOrder == null) {
      print('_ProfilePageState._getCachedData profile == null');
      await _getProfileFromFirestore();
    } else {
      _setFields();
    }
  }

  _setFields() {
    controllerMaxInvestable.text = '${profile.maxInvestableAmount}';
    controllerMaxInvoice.text = '${profile.maxInvoiceAmount}';
    maxInvestableAmount = profile.maxInvestableAmount;
    maxInvoiceAmount = profile.maxInvoiceAmount;
    if (profile.suppliers != null) {
      numberOfSuppliers = profile.suppliers.length;
    }
    if (profile.sectors != null) {
      numberOfSectors = profile.sectors.length;
    }
    if (profile.minimumDiscount != null) {
      minimum = profile.minimumDiscount;
    } else {
      minimum = 0.0;
    }
    setState(() {});
  }

  @override
  onActionPressed(int action) {
    switch (action) {
      case 3:
        if (order == null) {
          _showAutoTradeDialog();
        } else {
          Navigator.pop(context);
        }
        break;
      case 4:
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  AutoTradeOrder autoTradeOrder;
  _showAutoTradeDialog() async {
    if (autoTradeOrder != null) {
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Auto Trade Confirmation",
                style: Styles.greyLabelMedium,
              ),
              content: Container(
                height: 200.0,
                child: Text(
                    'Do you  want to set up or update an Auto Trade Order?  The network will make automatic invoice offers on your behalf if you want to.'),
              ),
              actions: <Widget>[
                FlatButton(onPressed: _onNoAutoTrade, child: Text('NO')),
                FlatButton(onPressed: _onAutoTrade, child: Text('YES')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Investor Profile',
          style: Styles.whiteBoldMedium,
        ),
        bottom: _getBottom(),
      ),
      backgroundColor: Colors.brown.shade100,
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          elevation: 2.0,
          child: _getForm(),
        ),
      ),
    );
  }

  _onSubmit() async {
    print('_ProfilePageState._onSubmit ........................');
    if (controllerMaxInvestable.text.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter maximum investible amount',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    if (controllerMaxInvoice.text.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter maximum invoice amount ',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    if (minimum == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter minimum invoice discount ',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    if (profile == null) {
      profile = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
      );
    }
    try {
      profile.minimumDiscount = minimum;
      profile.maxInvestableAmount = double.parse(controllerMaxInvestable.text);
      profile.maxInvoiceAmount = double.parse(controllerMaxInvoice.text);
    } catch (e) {
      print('_ProfilePageState._onSubmit $e');
    }
    profile.investor = investor.participantId;
    List<String> sectorStrings = List();

    if (selectedSectors != null) {
      selectedSectors.forEach((sec) {
        sectorStrings.add('resource:com.oneconnect.biz.Sector#${sec.sectorId}');
      });
      profile.sectors = sectorStrings;
    }

    List<String> suppStrings = List();
    if (selectedSuppliers != null) {
      selectedSuppliers.forEach((sec) {
        suppStrings
            .add('resource:com.oneconnect.biz.Supplier#${sec.participantId}');
      });
      profile.suppliers = suppStrings;
    }
    profile.investor = investor.participantId;
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Saving profile ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    try {
      profile = await DataAPI3.addInvestorProfile(profile);
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Profile saved',
          textColor: Styles.lightGreen,
          backgroundColor: Styles.black,
          actionLabel: 'OK',
          listener: this,
          icon: Icons.done_all,
          action: 3);
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Profile failed',
          listener: this,
          actionLabel: 'CLOSE');
    }
  }

  List<DropdownMenuItem<Sector>> sectorItems = List();
  List<DropdownMenuItem<Supplier>> supplierItems = List();

  String email;
  double maxInvestableAmount, maxInvoiceAmount;
  TextEditingController controllerMaxInvestable = TextEditingController();
  TextEditingController controllerMaxInvoice = TextEditingController();

  Widget _getForm() {
    if (investor == null) {
      print('_ProfilePageState._getForm %%%% investor is null');
    } else {
      print('_ProfilePageState._getForm: investor is OK');
    }
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 20.0, right: 20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    DropdownButton<String>(
                      items: items,
                      onChanged: _onMinimumChanged,
                      elevation: 4,
                      hint: Text(
                        'Minimum Discount',
                        style: Styles.blueSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        minimum == null ? '' : '$minimum %',
                        style: Styles.blackBoldLarge,
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelStyle: Styles.blackMedium,
                  labelText: 'Maximum Investable Amount',
                ),
                maxLength: 20,
                controller: controllerMaxInvestable,
                style: Styles.blackBoldLarge,
                onChanged: _onInvestableAmountChanged,
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelStyle: Styles.blackMedium,
                  labelText: 'Maximum Single Offer Amount',
                ),
                maxLength: 16,
                controller: controllerMaxInvoice,
                style: Styles.pinkBoldLarge,
                onChanged: _onInvoiceAmountChanged,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            'Investment Filters',
            style: Styles.greyLabelSmall,
          ),
        ),
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: _goToSectorList,
              child: Text(
                'Select Sectors',
                style: Styles.blueSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                selectedSectors == null
                    ? '$numberOfSectors'
                    : '${selectedSectors.length}',
                style: Styles.blackBoldMedium,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: _goToSuppliersList,
              child: Text(
                'Select Suppliers',
                style: Styles.blueSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                selectedSuppliers == null
                    ? '$numberOfSuppliers'
                    : '${selectedSuppliers.length}',
                style: Styles.blackBoldMedium,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 30.0, right: 30.0),
          child: RaisedButton(
            onPressed: _onSubmit,
            elevation: 8.0,
            color: Colors.indigo.shade300,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _setButton(),
                style: Styles.whiteSmall,
              ),
            ),
          ),
        ),
        autoTradeOrder == null
            ? Padding(
                padding: const EdgeInsets.only(
                    bottom: 30.0, left: 30.0, right: 30.0, top: 4.0),
                child: RaisedButton(
                  onPressed: _onSubmit,
                  elevation: 8.0,
                  color: Colors.indigo.shade300,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Add Auto Trade Order',
                      style: Styles.whiteSmall,
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Color _setColor() {
    if (profile == null) {
      return Styles.pink;
    } else {
      if (profile.profileId == null) {
        return Styles.pink;
      } else {
        return Styles.purple;
      }
    }
  }

  String _setButton() {
    if (profile == null) {
      return 'Submit Profile';
    } else {
      if (profile.profileId == null) {
        return 'Submit Profile';
      } else {
        return 'Update Profile';
      }
    }
  }

  Future _getProfileFromFirestore() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading profile ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    profile = await ListAPI.getInvestorProfile(investor.participantId);
    autoTradeOrder = await ListAPI.getAutoTradeOrder(investor.participantId);
    _scaffoldKey.currentState.removeCurrentSnackBar();

    if (profile != null) {
      await SharedPrefs.saveInvestorProfile(profile);
      _setFields();
    }
    if (order != null) {
      await SharedPrefs.saveAutoTradeOrder(order);
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    investor == null ? 'Organisation' : investor.name,
                    style: Styles.whiteSmall,
                  ),
                ),
              )
            ],
          ),
          StreamBuilder<String>(
            stream: investorBloc.fcmStream,
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

  List<Supplier> selectedSuppliers;
  List<Sector> selectedSectors;

  void _goToSectorList() async {
    if (profile == null) {
      profile = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
        date: getUTCDate(),
        maxInvestableAmount: maxInvestableAmount,
        maxInvoiceAmount: maxInvoiceAmount,
        email: email,
      );
      profile.suppliers = List<String>();
      profile.sectors = List<String>();
    }

    selectedSectors = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new SectorListPage(
              profile: profile,
            ),
      ),
    );
    setState(() {});
    print(
        '_ProfilePageState._onSectors BACK froom SectorListPage selectedSectors: ${selectedSectors.length}');
  }

  void _goToSuppliersList() async {
    if (profile == null) {
      profile = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
        date: getUTCDate(),
        maxInvestableAmount: maxInvestableAmount,
        maxInvoiceAmount: maxInvoiceAmount,
        email: email,
      );
      profile.suppliers = List<String>();
      profile.sectors = List<String>();
    }

    selectedSuppliers = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new SupplierListPage(
              profile: profile,
            ),
      ),
    );
    setState(() {});
    print(
        '_ProfilePageState._onSuppliers BACK froom SupplierListPage selectedSuppliers: ${selectedSuppliers.length}');
  }

  void _onInvestableAmountChanged(String value) {
    maxInvestableAmount = double.parse(value);
    print(
        '_ProfilePageState._onInvestableAmountChanged maxInvestableAmount: $maxInvestableAmount');
  }

  void _onInvoiceAmountChanged(String value) {
    maxInvoiceAmount = double.parse(value);
    print(
        '_ProfilePageState._onInvoiceAmountChanged maxInvoiceAmount:  $maxInvoiceAmount');
  }

  void _onNoAutoTrade() {
    Navigator.pop(context);
  }

  void _onAutoTrade() async {
    Navigator.pop(context);
    var user = await SharedPrefs.getUser();
    var wallet = await SharedPrefs.getWallet();
    if (wallet == null) {
      wallet = await ListAPI.getWallet(participantId: investor.participantId);
      await SharedPrefs.saveWallet(wallet);
    }
    var orderCached = await SharedPrefs.getAutoTradeOrder();
    AutoTradeOrder order;
    if (orderCached != null) {
      order = orderCached;
      order.wallet = wallet.stellarPublicKey;
    } else {
      order = AutoTradeOrder(
          date: getUTCDate(),
          investorName: investor.name,
          investorProfile: profile.profileId,
          investor: investor.participantId,
          user: user.userId,
          wallet: wallet.stellarPublicKey);
    }
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Saving Auto Trade Order',
        textColor: Styles.yellow,
        backgroundColor: Styles.black);

    var res;
    if (orderCached != null) {
      res = await DataAPI3.updateAutoTradeOrder(order);
    } else {
      res = await DataAPI3.addAutoTradeOrder(order);
    }
    if (res == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Failed to add Auto Trade Order',
          listener: this,
          actionLabel: 'CLOSE');
    } else {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Auto Trade Order saved',
          textColor: Styles.yellow,
          backgroundColor: Styles.black,
          listener: this,
          actionLabel: 'OK',
          icon: Icons.done_all,
          action: 4);
    }
  }

  double minimum;
  List<DropdownMenuItem<String>> items = List();
  void _setItems() {
    print('_MakeOfferPageState._setItems ................');

    var item7 = DropdownMenuItem<String>(
      value: '2.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.purple,
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
              color: Colors.purple,
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
              color: Colors.red,
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
              color: Colors.red,
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
              color: Colors.red,
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
              color: Colors.red,
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
              color: Colors.red,
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
              color: Colors.red,
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
              color: Colors.red,
            ),
          ),
          Text('10 %'),
        ],
      ),
    );
    items.add(item15);
  }

  void _onMinimumChanged(String value) {
    minimum = double.parse(value);
    setState(() {});
  }
}
