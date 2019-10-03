import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class SupplierListPage extends StatefulWidget {
  final InvestorProfile profile;

  const SupplierListPage({this.profile});
  @override
  _SupplierListPageState createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Supplier> suppliers, selectedSuppliers = List();
  InvestorProfile profile;
  @override
  void initState() {
    super.initState();
    _getSuppliers();
  }

  void _getSuppliers() async {
    suppliers = await ListAPI.getSuppliers();

    if (profile.suppliers != null && profile.suppliers.isNotEmpty) {
      profile.suppliers.forEach((supp) {
        suppliers.forEach((s) {
          if (s.participantId == supp.split('#').elementAt(1)) {
            selectedSuppliers.add(s);
          }
        });
      });
    }

    print(
        '_SupplierListPageState._getSuppliers selectedSuppliers: ${selectedSuppliers.length}');
    setState(() {});
  }

  _onDeleteSupplier(Supplier supplier) {
    selectedSuppliers.remove(supplier);
    Navigator.pop(context);
    setState(() {});
    print(
        '_ProfilePageState._onDeleteSupplier - deleted supplier: ${supplier.toJson()}');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: '${supplier.name} removed from list',
        textColor: Styles.white,
        backgroundColor: Styles.black);
  }

  _showSelectedSuppliers() {
    if (selectedSuppliers.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No suppliers in your profile',
          listener: this,
          actionLabel: 'CLOSE');
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Column(
                children: <Widget>[
                  Text(
                    "Investor Supplier List",
                    style: Styles.tealBoldMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Tap to Remove Supplier",
                      style: Styles.pinkBoldSmall,
                    ),
                  ),
                ],
              ),
              content: Container(
                height: 200.0,
                child: ListView.builder(
                    itemCount: selectedSuppliers == null
                        ? 0
                        : selectedSuppliers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        onTap: () {
                          _onDeleteSupplier(selectedSuppliers.elementAt(index));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.apps,
                                  color: Styles.teal,
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  child: Text(
                                    '${selectedSuppliers.elementAt(index).name}',
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _ignore,
                  child: Text('Close'),
                ),
              ],
            ));
  }

  _ignore() {
    Navigator.pop(context);
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  Widget build(BuildContext context) {
    profile = widget.profile;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('BFN Investor Suppliers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 68.0),
                  child: Icon(
                    Icons.list,
                    color: Styles.white,
                  ),
                ),
                FlatButton(
                  onPressed: _showSelectedSuppliers,
                  child: Text(
                    'View Selected Suppliers',
                    style: Styles.whiteMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: suppliers == null ? 0 : suppliers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                        onTap: () {
                          if (suppliers.isNotEmpty) {
                            _onSelected(suppliers.elementAt(index));
                          }
                        },
                        child: new SupplierCard(suppliers.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFinish,
        elevation: 8.0,
        backgroundColor: Styles.pink,
        child: Icon(Icons.done),
      ),
    );
  }

  _onFinish() {
    print(
        '_SupplierListPageState._onFinish selectedSuppliers: ${selectedSuppliers.length}');
    Navigator.pop(context, selectedSuppliers);
  }

  _showRemoveDialog(Supplier supplier) {
    this.supplier = supplier;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Supplier Removal",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Styles.pink),
              ),
              content: Flexible(
                child: Container(
                  height: 60.0,
                  child: Text(
                    'Do you want to remove ${supplier.name} from your supplier list?',
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onRemoveSupplier,
                  child: Text(
                    'REMOVE',
                    style: Styles.pinkBoldMedium,
                  ),
                ),
              ],
            ));
  }

  Supplier supplier;
  _showAddDialog(Supplier supplier) {
    this.supplier = supplier;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Supplier Addition",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 60.0,
                child: Text(
                    'Do you want to add ${supplier.name} to your supplier list?'),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onAddSupplier,
                  child: Text('ADD SUPPLIER'),
                ),
              ],
            ));
  }

  _onSelected(Supplier supplier) {
    print('_SupplierListPageState._onSelected selectted ${supplier.name}');
    bool isFound = false;
    selectedSuppliers.forEach((supp) {
      if (supplier.participantId == supp.participantId) {
        isFound = true;
      }
    });
    if (isFound) {
      _showRemoveDialog(supplier);
    } else {
      _showAddDialog(supplier);
    }
  }

  void _onNoPressed() {
    Navigator.pop(context);
  }

  _onRemoveSupplier() {
    Navigator.pop(context);
    selectedSuppliers.remove(supplier);
    print(
        '_SupplierListPageState._onRemoveSupplier removed: ${supplier.name} selectedSuppliers: ${selectedSuppliers.length}');
    //setState(() {});
  }

  _onAddSupplier() {
    Navigator.pop(context);
    selectedSuppliers.add(supplier);
    print(
        '_SupplierListPageState._onAddSupplier added supplier: ${supplier.name} selectedSuppliers: ${selectedSuppliers.length}');
    //setState(() {});
  }
}
