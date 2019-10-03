import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';

class CustomerList extends StatefulWidget {
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Customer> entities;
  User user;
  Supplier supplier;

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  _getCached() async {
    print('_GovtEntitiesListState._getCached ......');
    supplier = await SharedPrefs.getSupplier();
    if (supplier != null) {
      _getEntities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Government Entities'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: entities == null ? 0 : entities.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          onTap: () {
                            var ent = entities.elementAt(index);
                            print(
                                'GovtEntitiesList.build about to pop ${ent.name}');
                            Navigator.pop(context, ent);
                          },
                          child: new GovtEntityCard(entities.elementAt(index)));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  void _getEntities() async {
    print('_GovtEntitiesListState._getEntities ............');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading Governement entities',
        textColor: Colors.white,
        backgroundColor: Colors.black);

//    entities = await ListAPI.getGovtEntitiesByCountry(supplier.country);
    setState(() {});
  }
}

class GovtEntityCard extends StatelessWidget {
  final Customer entity;

  GovtEntityCard(this.entity);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Container(
        height: 40.0,
        child: Card(
          elevation: 1.0,
          child: ListTile(
            leading: Icon(Icons.location_on),
            title: Text(
              entity.name,
            ),
          ),
        ),
      ),
    );
  }
}
