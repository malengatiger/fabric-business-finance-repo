import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/country.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/message.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:customer/customer_bloc.dart';
import 'package:customer/ui/dashboard.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    implements SnackBarListener, CustomerModelBlocListener {
  String name,
      email,
      address,
      cellphone,
      firstName,
      lastName,
      adminEmail,
      password,
      adminCellphone,
      idNumber;
  bool autoAccept = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String participationId;
  List<DropdownMenuItem> items = List();
  Country country;
  var govtEntityType;
  var btnOpacity = 1.0;
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
      name = '${entities.elementAt(rand.nextInt(entities.length - 1))}';

      email = 'info$num@customeremail.co.za';
      firstName =
          '${firstNames.elementAt(rand.nextInt(firstNames.length - 1))}';
      lastName = '${lastNames.elementAt(rand.nextInt(lastNames.length - 1))}';
      adminEmail =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}$num@customeremail.co.za';
      password = 'pass123';
      autoAccept = true;
      country = Country(name: 'South Africa', code: 'ZA');
    }
  }

  _getCountry() async {
    country = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CountrySelectorPage()),
    );
    setState(() {});
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      DataAPI3.addSectors();
    }
  }

  List<Sector> sectors;

  var style = TextStyle(
      fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    List<ListTile> tiles = List();
    messages.forEach((m) {
      tiles.add(ListTile(
        title: Text(m.message),
        leading: Icon(
          Icons.cloud_download,
          color: getRandomColor(),
        ),
      ));
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Customer SignUp'),
      ),
      body: Form(
        key: _formKey,
        child: new Padding(
          padding: const EdgeInsets.all(4.0),
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  new Opacity(
                    opacity: 0.5,
                    child: Text(
                      'Organisation Details',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Allow Invoice Acceptance?',
                        style: Styles.greyLabelSmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child:
                            Switch(value: autoAccept, onChanged: _autoChanged),
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: name == null ? '' : name,
                    style: style,
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
                    initialValue: email == null ? '' : email,
                    style: style,
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
                    child: new Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Administrator Details',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  TextFormField(
                    initialValue: firstName == null ? '' : firstName,
                    style: style,
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
                    initialValue: lastName == null ? '' : lastName,
                    style: style,
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
                    initialValue: name == adminEmail ? '' : adminEmail,
                    style: style,
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
                    initialValue: password == null ? '' : password,
                    style: style,
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
                          style: TextStyle(color: Colors.blue, fontSize: 16.0),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          country == null ? '' : country.name,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  btnOpacity == 0
                      ? Container()
                      : new Padding(
                          padding: const EdgeInsets.only(
                              left: 28.0, right: 20.0, top: 30.0),
                          child: RaisedButton(
                            elevation: 8.0,
                            color: Colors.red.shade900,
                            onPressed: _onSubmit,
                            child: new Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Register to BFN',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                            ),
                          ),
                        ),
                  tiles.isEmpty
                      ? Container()
                      : Column(
                          children: tiles,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isBusy = false;
  void _onSubmit() async {
    if (isBusy) {
      return;
    }
    isBusy = true;
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      Customer customer = Customer(
        name: name,
        email: email,
        country: country.name,
        allowAutoAccept: autoAccept,
        dateRegistered: getUTCDate(),
      );
      if (EmailValidator.validate(email) == false) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Email is in wrong format',
            listener: this,
            actionLabel: 'Close');
        return;
      }
      print('_SignUpPageState._onSavePressed ${customer.toJson()}');
      User admin = User(
          firstName: firstName,
          lastName: lastName,
          email: adminEmail,
          password: password,
          isAdministrator: true);
      print('_SignUpPageState._onSavePressed ${admin.toJson()}');
      AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Customer Sign Up ... ',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black,
      );
      setState(() {
        btnOpacity = 0.0;
      });
      try {
        await DataAPI3.addCustomer(customer, admin);
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Dashboard('Customer signed up!')));
      } catch (e) {
        _showSignUpError(e.message);
      }
    }
  }

  void _showSignUpError(String message) {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        listener: this,
        actionLabel: 'CLOSE');
  }

  void exit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }

  @override
  onActionPressed(int action) {
    exit();
  }

  void _autoChanged(bool value) {
    print('_SignUpPageState._autoChanged: value = $value');
    autoAccept = value;
    setState(() {});
  }

  List<String> firstNames = [
    'Maria',
    'Jonathan',
    'David',
    'Thabiso',
    'Fikile',
    'Peter',
    'John',
    'Donald',
    'Malenga',
    'Thomas',
    'Catherine',
    'Portia',
    'Helen',
    'Suzanne',
    'Jennifer',
    'Nothando'
  ];
  List<String> lastNames = [
    'Nkosi',
    'Maluleke',
    'Hanyane',
    'Mokoena',
    'Chauke',
    'Thompson',
    'Simon',
    'Peterson',
    'Smith',
    'Mathebula',
    'Tottenkopf',
    'Kotze',
    'Lerner',
    'Samuels',
    'Johnson',
    'Carlson',
    'Brooks',
    'Charles'
  ];
  List<String> entities = [
    'Ace Supermarkets',
    'Thompson Engineering',
    'Pick & Take Supermarkets',
    'Hyundai Motors',
    'Netcare Hospitals',
    'Joburg Metro',
    'Tshwane Metro',
    'Madibeng Municipality',
    'Fourways Mall',
    'Checkers Supermarkets',
    'Dept of Public Works',
    'Dept of Health',
    'Dept of Transport',
    'Dept of Education',
    'Dept of Communications',
    'Dept of Finance',
    'Dept of Social Services',
    'Brits Mining Works',
  ];

  List<Message> messages = List();
  @override
  onEvent(String message) {
    Message msg = Message(
      message: message,
      type: Message.GENERAL_MESSAGE,
    );
    setState(() {
      messages.add(msg);
    });
  }
}
