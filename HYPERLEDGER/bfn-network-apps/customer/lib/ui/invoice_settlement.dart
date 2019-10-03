import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:customer/customer_bloc.dart';
import 'package:flutter/material.dart';

class InvoiceSettlementPage extends StatefulWidget {
  final Invoice invoice;

  InvoiceSettlementPage(this.invoice);

  @override
  _InvoiceSettlementState createState() => _InvoiceSettlementState();
}

class _InvoiceSettlementState extends State<InvoiceSettlementPage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Invoice invoice;
  Customer entity;

  @override
  void initState() {
    super.initState();
    _getCache();
  }

  _getCache() async {
    print('_InvoiceSettlementState._getCache ... get cached entity');
    entity = await SharedPrefs.getCustomer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    this.invoice = widget.invoice;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Settlement'),
        elevation: 8.0,
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 28.0),
                  child: Text(
                    entity == null ? '' : entity.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 18.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Supplier',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                        ),
                        child: Text(
                          invoice == null ? '' : invoice.supplierName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          invoice == null ? '' : invoice.invoiceNumber,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 30.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          invoice == null ? '' : '${invoice.amount}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<String>(
                  stream: customerBloc.fcmStream,
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
            preferredSize: Size.fromHeight(200.0)),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 140.0),
              child: RaisedButton(
                elevation: 8.0,
                color: Colors.teal,
                onPressed: _settleInvoice,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Settle Invoice',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _settleInvoice() {
    prettyPrint(
        invoice.toJson(), '_InvoiceSettlementState._settleInvoice ......');
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'NOT IMPLEMENTED YET',
        textColor: Colors.white,
        icon: Icons.build,
        listener: this,
        action: 0,
        actionLabel: 'Close',
        backgroundColor: Colors.red.shade300);
  }

  @override
  onActionPressed(int action) {
    Navigator.pop(context);
  }
}
