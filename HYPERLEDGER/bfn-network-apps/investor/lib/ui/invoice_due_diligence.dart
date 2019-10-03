import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:flutter/material.dart';

class InvoiceDueDiligence extends StatefulWidget {
  final Offer offer;

  InvoiceDueDiligence(this.offer);

  @override
  _InvoiceDueDiligenceState createState() => _InvoiceDueDiligenceState();
}

class _InvoiceDueDiligenceState extends State<InvoiceDueDiligence> {
  PurchaseOrder purchaseOrder;
  SupplierContract supplierContract;
  List<DeliveryNote> deliveryNotes;
  List<DeliveryAcceptance> deliveryAcceptances;
  InvoiceAcceptance invoiceAcceptance;
  Invoice invoice;
  Offer offer;

  @override
  Widget build(BuildContext context) {
    offer = widget.offer;
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Due Diligence'),
      ),
    );
  }
}
