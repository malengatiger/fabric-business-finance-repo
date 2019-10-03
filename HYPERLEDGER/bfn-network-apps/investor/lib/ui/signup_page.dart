import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/investor_model_bloc.dart';
import 'package:businesslibrary/data/country.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/signup_util.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/dashboard.dart';
import 'package:investor/ui/profile.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    implements SnackBarListener, FCMListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var name,
      email,
      address,
      cellphone,
      firstName,
      lastName,
      adminEmail,
      password,
      adminCellphone,
      idNumber;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String participationId;

  Country country;
  @override
  initState() {
    super.initState();
    _debug();
    _checkSectors();
  }

  _debug() {
    if (isInDebugMode) {
      Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
      var num = rand.nextInt(10000);
      name = '${investors.elementAt(rand.nextInt(investors.length - 1))}';
      adminEmail = 'admin$num@gov.co.za';
      email = 'info$num@gov.co.za';
      firstName =
          '${firstNames.elementAt(rand.nextInt(firstNames.length - 1))}';
      lastName = '${lastNames.elementAt(rand.nextInt(lastNames.length - 1))}';
      password = 'pass123';
      country = Country(name: 'South Africa', code: 'ZA');
    }
  }

  _getCountry() async {
    country = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CountrySelectorPage()),
    );
    print(
        '_SignUpPageState._getCountry - back from selection: ${country.name}');
    setState(() {});
  }

  var style = TextStyle(
      fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Investor SignUp'),
      ),
      body: Form(
        key: _formKey,
        child: new Padding(
          padding: const EdgeInsets.all(4.0),
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  Text(
                    'Organisation Details',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w900),
                  ),
                  TextFormField(
                    style: style,
                    initialValue: name == null ? '' : name,
                    decoration: InputDecoration(
                        labelText: 'Organisation Name',
                        hintText: 'Enter organisation name'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the name';
                      }
                    },
                    onSaved: (val) => name = val,
                  ),
                  TextFormField(
                    style: style,
                    initialValue: adminEmail == null ? '' : adminEmail,
                    decoration: InputDecoration(
                      labelText: 'Organisation email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the email';
                      }
                    },
                    onSaved: (val) => email = val,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Text(
                      'Administrator Details',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextFormField(
                    style: style,
                    initialValue: firstName == null ? '' : firstName,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your first name';
                      }
                    },
                    onSaved: (val) => firstName = val,
                  ),
                  TextFormField(
                    style: style,
                    initialValue: lastName == null ? '' : lastName,
                    decoration: InputDecoration(
                      labelText: 'Surname',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your surname';
                      }
                    },
                    onSaved: (val) => lastName = val,
                  ),
                  TextFormField(
                    style: style,
                    initialValue: adminEmail == null ? '' : adminEmail,
                    decoration: InputDecoration(
                      labelText: 'Administrator Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your email address';
                      }
                    },
                    onSaved: (val) => adminEmail = val,
                  ),
                  TextFormField(
                    style: style,
                    initialValue: password == null ? '' : password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    maxLength: 20,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your password';
                      }
                    },
                    onSaved: (val) => password = val,
                  ),
                  Column(
                    children: <Widget>[
                      new InkWell(
                        onTap: _getCountry,
                        child: Text(
                          'Get Country',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Text(
                        country == null ? '' : country.name,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                        left: 28.0, right: 20.0, top: 30.0),
                    child: RaisedButton(
                      elevation: 8.0,
                      color: Theme.of(context).accentColor,
                      onPressed: _onSubmit,
                      child: new Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Submit SignUp',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (EmailValidator.validate(adminEmail) == false) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Email is in wrong format',
            listener: this,
            actionLabel: 'Close');
        return;
      }
      Investor investor = Investor(
        name: name,
        email: email,
        country: country.name,
        dateRegistered: getUTCDate(),
      );
      print('_SignUpPageState._onSavePressed ${investor.toJson()}');
      User admin = User(
          firstName: firstName,
          lastName: lastName,
          email: adminEmail,
          password: password,
          isAdministrator: true);
      print('_SignUpPageState._onSavePressed ${admin.toJson()}');
      AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Investor Sign Up ... ',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black,
      );

      try {
        investor = await DataAPI3.addInvestor(investor, admin);
        AppSnackbar.showSnackbarWithAction(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Sign Up and Wallet OK',
            textColor: Colors.white,
            backgroundColor: Colors.teal,
            actionLabel: 'Start',
            action: 0,
            icon: Icons.done_all);
        exit();
      } catch (e) {
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: e.message,
            actionLabel: "Support");
      }
    }
  }

  void checkResult(int result, Investor investor) async {
    switch (result) {
      case SignUp.Success:
        print('_SignUpPageState._onSavePressed SUCCESS!!!!!!');

        var wallet = SharedPrefs.getWallet();
        if (wallet != null) {
          AppSnackbar.showSnackbarWithAction(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Sign Up and Wallet OK',
              textColor: Colors.white,
              backgroundColor: Colors.teal,
              actionLabel: 'Start',
              action: 0,
              icon: Icons.done_all);
          await investorModelBloc.refreshDashboard();
          checkProfile();
        } else {
          //TODO - wallet not on blockchain.
          exit();
        }

        break;
      case SignUp.ErrorBlockchain:
        print('_SignUpPageState._onSavePressed  ErrorBlockchain');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Blockchain failed to process Sign Up',
            actionLabel: "Support");
        break;
      case SignUp.ErrorMissingOrInvalidData:
        print('_SignUpPageState._onSavePressed  ErrorMissingOrInvalidData');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Missing or Invalid data in the form',
            actionLabel: "Support");
        break;
      case SignUp.ErrorFirebaseUserExists:
        print('_SignUpPageState._onSavePressed  ErrorFirebaseUserExists');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'This user already  exists',
            actionLabel: "Close");
        break;
      case SignUp.ErrorFireStore:
        print('_SignUpPageState._onSavePressed  ErrorFireStore');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Database Error',
            actionLabel: "Support");
        break;
      case SignUp.ErrorCreatingFirebaseUser:
        print('_SignUpPageState._onSavePressed  ErrorCreatingFirebaseUser');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Database Error',
            actionLabel: "Support");
        break;
    }
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      DataAPI3.addSectors();
    }
  }

  List<Sector> sectors;

  void exit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }

  void checkProfile() async {
    var profile = await SharedPrefs.getInvestorProfile();
    if (profile == null) {
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new ProfilePage(),
          ));
    }
  }

  @override
  onActionPressed(int action) {
    exit();
  }

  List<String> firstNames = [
    'Mark',
    'Jonathan',
    'David',
    'Jennifer',
    'Catherine',
    'Henry'
  ];
  List<String> lastNames = [
    'Jones',
    'van der Merwe',
    'Franklin',
    'Henderson',
    'Samuels',
    'Bergh',
    'Davidson',
  ];
  List<String> investors = [
    'Invoice Financiers',
    'Black Ox Capital',
    'Finance LLC',
    'SME Investors LLC',
    'TradeFinance Pty Ltd',
    'Finance Gurus LLC',
    'African Financial Services',
    'Southern Finance LLC',
    'Gauteng Finance Brokers',
    'Samuelson LLC',
    'Johannesburg Finance',
    'Finance Gurus Pty Ltd',
    'BlueBull Financiers',
    'Hennessey Invoice Funds LLC',
  ];

  @override
  onInvoiceBidMessage(invoiceBid) {
    // TODO: implement onInvoiceBidMessage
  }

  @override
  onHeartbeat(Map map) {
    // TODO: implement onHeartbeat
  }

  @override
  onOfferMessage(Offer offer) {
    // TODO: implement onOfferMessage
    return null;
  }
}
