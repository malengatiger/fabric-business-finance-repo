import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:flutter/material.dart';

class SupplierListPage extends StatefulWidget {
  @override
  _SupplierListPageState createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Supplier> suppliers;
  @override
  void initState() {
    super.initState();
    _getSuppliers();
  }

  void _getSuppliers() async {
    suppliers = await ListAPI.getSuppliers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('BFN Suppliers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Row(),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: suppliers == null ? 0 : suppliers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          onTap: () {
                            var supp = suppliers.elementAt(index);
                            print(
                                '_SupplierListPageState.build about to pop ${supp.name}');
                            Navigator.pop(context, supp);
                          },
                          child: new SupplierCard(suppliers.elementAt(index)));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
