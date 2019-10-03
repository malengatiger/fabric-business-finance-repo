import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/contract_page.dart';

class ContractList extends StatefulWidget {
  @override
  _ContractListState createState() => _ContractListState();
}

class _ContractListState extends State<ContractList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<SupplierContract> contracts;
  Supplier supplier;
  User user;

  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();

    _getCachedPrefs();
  }

  _getCachedPrefs() async {
    _opacity = 1.0;
    setState(() {});
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    contracts = await ListAPI.getSupplierContracts(supplier.participantId);
    if (contracts == null || contracts.isEmpty) {
      _showNoContractsDialog();
    } else {
      double total = 0.00;
      contracts.forEach((ct) {
        var end = DateTime.parse(ct.endDate).toUtc();
        if (DateTime.now().isBefore(end)) {
          double val = double.parse(ct.estimatedValue);
          total += val;
        }
      });
      totalValue = getFormattedAmount('$total', context);
    }
    _opacity = 0.0;
    setState(() {});
  }

  _showNoContractsDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Contract Documents",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Contract Documents',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "There are no contracts uploaded to the Business Finance Network?",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  String totalValue;
  TextStyle getWhiteText() {
    return TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    );
  }

  TextStyle getBoldWhiteText() {
    return TextStyle(
        color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w900);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Contracts',
          style: Styles.whiteBoldMedium,
        ),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    supplier == null ? '' : supplier.name,
                    style: Styles.whiteSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Current Value:',
                          style: Styles.whiteSmall,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            totalValue == null ? '0.00' : totalValue,
                            style: Styles.whiteBoldMedium,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 28.0),
                            child: Container(
                                width: 16.0,
                                height: 16.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<String>(
                    stream: supplierBloc.fcmStream,
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
            ),
            preferredSize: Size.fromHeight(100.0)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddNewContract,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getCachedPrefs,
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: new ListView.builder(
            itemCount: contracts == null ? 0 : contracts.length,
            itemBuilder: (BuildContext context, int index) {
              return new InkWell(
                onTap: () {
                  _confirm(contracts.elementAt(index));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: SupplierContractCard(
                    supplierContract: contracts.elementAt(index),
                    context: context,
                  ),
                ),
              );
            }),
      ),
    );
  }

  void _onAddNewContract() async {
    var res = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ContractPage(null)),
    );
    if (res != null && res) {
      _getCachedPrefs();
    }
  }

  void _confirm(SupplierContract contract) {
    prettyPrint(contract.toJson(), '_ContractListState._confirm:');
  }
}

class SupplierContractCard extends StatelessWidget {
  final SupplierContract supplierContract;
  final BuildContext context;

  SupplierContractCard({this.supplierContract, this.context});

  @override
  Widget build(BuildContext context) {
    amount = _getFormattedAmt();
    return Card(
      elevation: 2.0,
      color: Colors.indigo.shade50,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Text(
                  getFormattedDateLong(supplierContract.date, context),
                  style: Styles.blackSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: <Widget>[
                Text(
                  supplierContract.customerName,
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 0.0, top: 10.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Value',
                  style: Styles.greyLabelSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    amount == null ? '0.00' : amount,
                    style: Styles.tealBoldMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Expiry Date',
                  style: Styles.greyLabelSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    supplierContract == null
                        ? 'No Date'
                        : getFormattedDate(supplierContract.endDate),
                    style: Styles.blackBoldSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String amount;
  String _getFormattedAmt() {
    amount = getFormattedAmount(supplierContract.estimatedValue, context);
    print('SupplierContractCard._getFormattedAmt $amount');
    return amount;
  }
}
