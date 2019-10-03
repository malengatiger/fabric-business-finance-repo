import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/util/page_util/data.dart';
import 'package:businesslibrary/util/page_util/intro_page_view.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:customer/ui/dashboard.dart';
import 'package:customer/ui/signin_page.dart';
import 'package:customer/ui/signup_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(new CustomerApp());

class CustomerApp extends StatefulWidget {
  @override
  _CustomerAppState createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  int themeIndex;

  @override
  void initState() {
    super.initState();
  }

  void getCached() async {
    themeIndex = await SharedPrefs.getThemeIndex();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      initialData: themeIndex == null ? 0 : themeIndex,
      stream: themeBloc.newThemeStream,
      builder: (context, snapShot) => MaterialApp(
            title: 'BFNCustomer',
            debugShowCheckedModeBanner: false,
            theme: snapShot.data == null
                ? ThemeUtil.getTheme(themeIndex: themeIndex)
                : ThemeUtil.getTheme(themeIndex: snapShot.data),
            home: new StartPage(),
          ),
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => new _StartPageState();
}

class _StartPageState extends State<StartPage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double fabOpacity = 0.3;
  Customer customer;
  @override
  initState() {
    super.initState();
    _check();
  }

  void _check() async {
    customer = await SharedPrefs.getCustomer();
    if (customer != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => Dashboard(null)),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('BFN'),
      ),
      body: Stack(
        children: <Widget>[
          new Opacity(
            opacity: 0.4,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fincash.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          new Center(
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(
                      top: 110.0, left: 50.0, right: 30.0),
                  child: Text(
                    'To create a brand new Customer Account press the button below. To do this, you must be an Administrator or Manager',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: RaisedButton(
                    onPressed: _startSignUpPage,
                    color: Theme.of(context).primaryColor,
                    elevation: 16.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Start New CustomerAccount',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding:
                      const EdgeInsets.only(top: 80.0, left: 50.0, right: 30.0),
                  child: Text(
                    'To sign in to an existing Customer Account press the button below.',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: _startSignInPage,
                    color: Colors.blue,
                    elevation: 16.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Sign in to Customer App',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: _startOnboarding,
                    color: Colors.pink,
                    elevation: 16.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Information',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _startOnboarding() {
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new IntroPageView(
                items: sampleItems,
                user: null,
              )),
    );
  }

  void _startSignUpPage() async {
    print('_MyHomePageState._btnPressed ................');
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignUpPage()),
    );
  }

  void _startSignInPage() async {
    print('_MyHomePageState._startSignInPage ...........');
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignInPage()),
    );
  }

  @override
  onActionPressed(int action) {
    print('_StartPageState.onActionPressed +++++++++++++++++ >>>');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }
}

class BackImage extends StatelessWidget {
  final AssetImage _assetImage = AssetImage('assets/fincash.jpg');
  @override
  Widget build(BuildContext context) {
    // var m = Image.asset('assets/fincash.jpg', fit: BoxFit.cover,)
    var image = new Opacity(
      opacity: 0.5,
      child: Image(
        image: _assetImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
    return Container(
      child: image,
    );
  }
}
