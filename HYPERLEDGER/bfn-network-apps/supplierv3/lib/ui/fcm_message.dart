import 'package:businesslibrary/data/purchase_order.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/supplier_bloc.dart';

class FCMMessageList extends StatelessWidget {
  final SupplierBloc bloc;

  FCMMessageList({@required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BFN Messages'),
      ),
    );
  }
}

class PurchaseOrderMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PurchaseOrder>(
      stream: supplierBloc.purchaseOrderMessageStream,
    );
  }
}
