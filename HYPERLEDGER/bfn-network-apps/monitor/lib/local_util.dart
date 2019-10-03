import 'dart:convert';

import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:web_socket_channel/io.dart';

class Util {}

abstract class BlockchainListener {
  onInvoiceBid(InvoiceBid bid);
  onOffer(Offer offer);
  onPurchaseOrder(PurchaseOrder purchaseOrder);
  onDeliveryNote(DeliveryNote deliveryNote);
  onInvoice(Invoice invoice);
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance);
  onInvoiceAcceptance(InvoiceAcceptance invoiceAcceptance);
}

class BlockchainUtil {
  static var channel =
      new IOWebSocketChannel.connect("ws://bfnrestv3.eu-gb.mybluemix.net");

  static listenForBlockchainEvents(BlockchainListener listener) async {
    print(
        'listenForBlockchainEvents ------- starting  #################################');
    channel.stream.listen((message) {
      print(
          '\n\n############# listenForBlockchainEvents WebSocket  ###################: \n\n' +
              message);
      try {
        var data = json.decode(message);
        String clazz = data['\$class'];
        if (clazz.contains('Offer')) {
          var m = data['offer'];
          var offer = Offer.fromJson(m);
          prettyPrint(offer.toJson(),
              'listenForBlockchainEvents ===============> Offer from web socket: ');
          listener.onOffer(offer);
          return;
        }
        if (clazz.contains('InvoiceBid')) {
          var m = data['bid'];
          var invoiceBid = InvoiceBid.fromJson(m);
          prettyPrint(invoiceBid.toJson(),
              'listenForBlockchainEvents ===============> InvoiceBid from web socket: ');
          listener.onInvoiceBid(invoiceBid);
          return;
        }
        if (clazz.contains('PurchaseOrder')) {
          var m = data['purchaseOrder'];
          var po = PurchaseOrder.fromJson(m);
          prettyPrint(po.toJson(),
              'listenForBlockchainEvents ===============> PurchaseOrder from web socket: ');
          listener.onPurchaseOrder(po);
          return;
        }
        if (clazz.contains('DeliveryNote')) {
          var m = data['deliveryNote'];
          var dn = DeliveryNote.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> DeliveryNote from web socket: ');
          listener.onDeliveryNote(dn);
          return;
        }
        if (clazz.contains('Invoice')) {
          var m = data['invoice'];
          var dn = Invoice.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> DeliveryNote from web socket: ');
          listener.onInvoice(dn);
          return;
        }
        if (clazz.contains('DeliveryAcceptance')) {
          var m = data['deliveryAcceptance'];
          var dn = DeliveryAcceptance.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> DeliveryAcceptance from web socket: ');
          listener.onDeliveryAcceptance(dn);
          return;
        }
        if (clazz.contains('InvoiceAcceptance')) {
          var m = data['invoiceAcceptance'];
          var dn = InvoiceAcceptance.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> InvoiceAcceptance from web socket: ');
          listener.onInvoiceAcceptance(dn);
          return;
        }
      } catch (e) {
        print('listenForBlockchainEvents ERROR $e');
      }
    });
  }
}
