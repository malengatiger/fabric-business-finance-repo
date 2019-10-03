import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/api_bag.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/constants.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';

abstract class GenListener {
  onEvent(String message, bool isRecordAdded);
  onPhaseComplete(int records);
  onError(String message);
  onResetCounter();
}

class Generator {
  static List<Customer> _customers;
  static List<Supplier> _suppliers;
  static List<Unit> _units = List();
  static int index = 0;
  static Random rand = Random(DateTime.now().millisecondsSinceEpoch);
  static List<Future> futures = List();
  static List<Sector> _sectors = List();
  static List<Investor> _investors = List();
  static List<InvestorProfile> _profiles = List();
  static GenListener _genListener;
  static List<PurchaseOrder> _purchaseOrders = List();
  static List<DeliveryNote> _deliveryNotes = List();
  static List<DeliveryAcceptance> _deliveryAcceptances = List();
  static List<Invoice> _invoices = List();
  static List<InvoiceAcceptance> _invoiceAcceptances = List();
  static List<Offer> _offers = List();
//  static List<User> _users = List();
  static List<AutoTradeOrder> _orders;
  static const PAGE_SIZE = 25;

  static Future generate(GenListener listener) async {
    _genListener = listener;
    var start = DateTime.now();
    print(
        '\n\n 🔵 🔵 🔵 🔵 🔵  Generator.generate business trades starting ... 🥦 🥦 🥦 \n\n');
    _genListener.onEvent('🔵  🔵  🔵  🔵  🔵 loading data ....', false);
    _customers = await ListAPI.getCustomersByCountry(country: 'ZA');
    _genListener.onEvent('💦  💦  💦 ${_customers.length} customers', false);

    _suppliers = await ListAPI.getSuppliers();
    _genListener.onEvent('💦  💦  💦 ${_suppliers.length} suppliers', false);

    _sectors = await ListAPI.getSectors();
    _genListener.onEvent('💦  💦  💦 ${_sectors.length} sectors', false);

//    _users = await ListAPI.getUsers();
    _units = List();

    _customers.forEach((customer) {
      _suppliers.forEach((supplier) {
        _units.add(Unit(customer, supplier));
      });
    });
    print(
        '\n\n💦  💦  💦  Generator: number of units:   🔵  🔵 ${_units.length} to process\n\n');
    _genListener.onEvent(
        '💦 💦  units to process: ${_units.length} 🔵 🔵 ', false);

    _deliveryNotes = List();
    _deliveryAcceptances = List();
    _invoices = List();
    _invoiceAcceptances = List();
    _offers = List();

//    await _processProfiles();
//    await _processAutoTradeOrders();
    await _processPurchaseOrders();
    await _processDeliveryNotes();
    await _processDeliveryAcceptances();
    await _processInvoices();
    await _processInvoiceAcceptances();
    await _processOffers();

    _genListener.onEvent('🔵 🔵️ 🔵 🔵️  JOB COMPLETE! ', false);
    var end = DateTime.now();
    _genListener.onEvent(
        '🔵 elapsed: ${end.difference(start).inSeconds} seconds, ⏰ ${end.difference(start).inMinutes} minutes',
        false);
  }

  static Future _processProfiles() async {
    print(
        '\n\n 🔵 🔵 🔵 🔵 🔵  Generator.generateProfilesAndOrders starting ...\n\n');
    _genListener.onEvent('🔵 🔵 🔵  loading investors ....', false);
    _investors = await ListAPI.getInvestors();
    _genListener.onEvent('🔵 🔵 🔵  ${_investors.length} investors', false);

    _profiles.clear();
    for (var investor in _investors) {
      InvestorProfile ip = InvestorProfile(
          investor: investor.participantId,
          name: investor.name,
          email: investor.email,
          minimumDiscount: _getRandomMinimumDisc(),
          maxInvestableAmount: _getRandomMaxInvestable(),
          maxInvoiceAmount: _getRandomMaxInvoice());
      var m = await DataAPI3.addInvestorProfile(ip);
      _profiles.add(m);
      _genListener.onEvent('🍊 🍊 profile added ${m.name}', true);
    }
    _genListener.onEvent(
        '🍊 🍊 🍊 🍊  ${_profiles.length} profiles added', false);
    _genListener.onPhaseComplete(_profiles.length);
    return null;
  }

  static Future _processAutoTradeOrders() async {
    _profiles = await ListAPI.getInvestorProfiles();
    if (_profiles.isEmpty) {
      _genListener.onEvent('💣 💣 💣  NO PROFILES FOUND, quit orders ', false);
      return null;
    }
    _orders = List();
    for (var profile in _profiles) {
      var autoTradeOrder = AutoTradeOrder(
          investor: profile.investor,
          investorProfile: profile.profileId,
          isCancelled: false,
          investorName: profile.name);
      var m = await DataAPI3.addAutoTradeOrder(autoTradeOrder);
      _orders.add(m);
      _genListener.onEvent(
          '🍏 🍏  added autoTradeOrder: ${m.investorName}', true);
    }
    _genListener.onEvent(
        '🍏 🍏 🍏️  ${_orders.length} autoTradeOrders added', false);
    _genListener.onPhaseComplete(_orders.length);
    return null;
  }

  static Future _processPurchaseOrders() async {
    var pos = List();
    for (var unit in _units) {
      var po = PurchaseOrder(
        purchaseOrderNumber: _getRandomPO(),
        supplier: unit.supplier.participantId,
        customer: unit.customer.participantId,
        amount: _getRandomPOAmount(),
        description: 'Generated Demo Purchase Order',
        supplierName: unit.supplier.name,
        purchaserName: unit.customer.name,
        date: DateTime.now().toUtc().toIso8601String(),
      );
      pos.add(po);
    }

    var rem = pos.length % PAGE_SIZE;
    var pages = pos.length ~/ PAGE_SIZE;
    if (rem > 0) {
      pages++;
    }

    index = 0;
    _purchaseOrders = List();
    for (var i = 0; i < pages; i++) {
      List<PurchaseOrder> poList = List();
      for (var j = 0; j < PAGE_SIZE; j++) {
        try {
          poList.add(pos.elementAt(index));
          index++;
        } catch (e) {
          print(e);
        }
      }
      _genListener.onEvent(
          '⚽️ sending ${poList.length} purchase orders', false);
      var bag = APIBag(
          jsonString: JsonEncoder().convert(poList),
          functionName: CHAIN_ADD_PURCHASE_ORDER,
          userName: DataAPI3.TemporaryUserName);
      try {
        var replyFromWeb = await _sendMultipleChaincodeTransactions(bag);
        List result = replyFromWeb['result'];
        result.forEach((m) {
          _purchaseOrders.add(PurchaseOrder.fromJson(m));
        });
      } catch (e) {
        print('\n\n👿  👿  👿  👿  👿  👿  👿  👿 ');
        print(e);
      }
    }
    _genListener.onEvent(
        '️🅿️️️ purchase orders generated: ${_purchaseOrders.length}', false);
    _genListener.onPhaseComplete(_purchaseOrders.length);
    return null;
  }

  static Future _processDeliveryNotes() async {
    if (_purchaseOrders.isEmpty) {
      _purchaseOrders = await ListAPI.getAllPurchaseOrders();
    }
    List<DeliveryNote> notes = List();
    for (var po in _purchaseOrders) {
      var note = DeliveryNote(
          supplierName: po.supplierName,
          amount: po.amount,
          purchaseOrderNumber: po.purchaseOrderNumber,
          purchaseOrder: po.purchaseOrderId,
          vat: po.amount * 0.15,
          supplier: po.supplier,
          customerName: po.purchaserName,
          totalAmount: po.amount * 1.15,
          customer: po.customer);
      notes.add(note);
    }

    var rem = notes.length % PAGE_SIZE;
    var pages = notes.length ~/ PAGE_SIZE;
    if (rem > 0) {
      pages++;
    }

    _deliveryNotes = List();
    index = 0;
    for (var i = 0; i < pages; i++) {
      List<DeliveryNote> dnList = List();
      for (var j = 0; j < PAGE_SIZE; j++) {
        try {
          dnList.add(notes.elementAt(index));
          index++;
        } catch (e) {
          print(e);
        }
      }
      _genListener.onEvent('⚽️ sending ${dnList.length} deliveryNotes', false);
      var bag = APIBag(
          jsonString: JsonEncoder().convert(dnList),
          functionName: CHAIN_ADD_DELIVERY_NOTE,
          userName: DataAPI3.TemporaryUserName);

      try {
        var replyFromWeb = await _sendMultipleChaincodeTransactions(bag);
        List result = replyFromWeb['result'];
        result.forEach((m) {
          _deliveryNotes.add(DeliveryNote.fromJson(m));
        });
      } catch (e) {
        print('\n\n👿  👿  👿  👿  👿  👿  👿  👿 ');
        print(e);
      }
    }
    _genListener.onEvent(
        '️🔱️ deliveryNotes generated: ${_deliveryNotes.length}', false);
    _genListener.onPhaseComplete(_deliveryNotes.length);
    return null;
  }

  static Future _processDeliveryAcceptances() async {
    if (_deliveryNotes.isEmpty) {
      _deliveryNotes = await ListAPI.getAllDeliveryNotes();
    }
    List<DeliveryAcceptance> acceptances = List();
    for (var note in _deliveryNotes) {
      var acc = DeliveryAcceptance(
        customer: note.customer,
        customerName: note.customerName,
        supplier: note.supplier,
        purchaseOrder: note.purchaseOrder,
        purchaseOrderNumber: note.purchaseOrderNumber,
        deliveryNote: note.deliveryNoteId,
      );
      acceptances.add(acc);
    }

    var rem = acceptances.length % PAGE_SIZE;
    var pages = acceptances.length ~/ PAGE_SIZE;
    if (rem > 0) {
      pages++;
    }

    _deliveryAcceptances = List();
    index = 0;
    for (var i = 0; i < pages; i++) {
      List<DeliveryAcceptance> accList = List();
      for (var j = 0; j < PAGE_SIZE; j++) {
        try {
          accList.add(acceptances.elementAt(index));
          index++;
        } catch (e) {
          print(e);
        }
      }
      _genListener.onEvent('⚽️ sending ${accList.length} deliveryAcks', false);
      var bag = APIBag(
          jsonString: JsonEncoder().convert(accList),
          functionName: CHAIN_ADD_DELIVERY_NOTE_ACCEPTANCE,
          userName: DataAPI3.TemporaryUserName);

      try {
        var replyFromWeb = await _sendMultipleChaincodeTransactions(bag);
        List result = replyFromWeb['result'];
        result.forEach((m) {
          _deliveryAcceptances.add(DeliveryAcceptance.fromJson(m));
        });
      } catch (e) {
        print('\n\n👿  👿  👿  👿  👿  👿  👿  👿 ');
        print(e);
      }
    }
    _genListener.onEvent(
        '🌺 deliveryAcks generated: ${_deliveryAcceptances.length}', false);
    _genListener.onPhaseComplete(_deliveryAcceptances.length);
    return null;
  }

  static Future _processInvoices() async {
    if (_deliveryNotes.isEmpty) {
      _deliveryNotes = await ListAPI.getAllDeliveryNotes();
      _deliveryAcceptances = await ListAPI.getAllDeliveryAcceptances();
    }

    var rem = _deliveryAcceptances.length % PAGE_SIZE;
    var pages = _deliveryAcceptances.length ~/ PAGE_SIZE;
    if (rem > 0) {
      pages++;
    }

    _invoices = List();
    index = 0;
    for (var i = 0; i < pages; i++) {
      List<Invoice> invList = List();
      for (var j = 0; j < PAGE_SIZE; j++) {
        try {
          var deliveryAcceptance = _deliveryAcceptances.elementAt(index);
          DeliveryNote note;
          _deliveryNotes.forEach((n) {
            if (deliveryAcceptance.deliveryNote == n.deliveryNoteId) {
              note = n;
            }
          });
          var invoice = Invoice(
            invoiceNumber: _getRandomInvoiceNumber(),
            customer: deliveryAcceptance.customer,
            supplier: deliveryAcceptance.supplier,
            purchaseOrder: deliveryAcceptance.purchaseOrder,
            deliveryNote: deliveryAcceptance.deliveryNote,
            supplierName: note.supplierName,
            customerName: deliveryAcceptance.customerName,
            purchaseOrderNumber: deliveryAcceptance.purchaseOrderNumber,
            amount: note.amount,
            valueAddedTax: note.vat,
            totalAmount: note.totalAmount,
            isOnOffer: false,
            isSettled: false,
            deliveryAcceptance: deliveryAcceptance.acceptanceId,
          );
          invList.add(invoice);
          index++;
        } catch (e) {
          print(e);
        }
      }
      _genListener.onEvent('⚽️ sending ${invList.length} invoices', false);
      var bag = APIBag(
          jsonString: JsonEncoder().convert(invList),
          functionName: CHAIN_ADD_INVOICE,
          userName: DataAPI3.TemporaryUserName);

      try {
        var replyFromWeb = await _sendMultipleChaincodeTransactions(bag);
        List result = replyFromWeb['result'];
        result.forEach((m) {
          _invoices.add(Invoice.fromJson(m));
        });
      } catch (e) {
        print('\n\n👿  👿  👿  👿  👿  👿  👿  👿 ');
        print(e);
      }
    }
    _genListener.onEvent('☘️️☘ invoices generated: ${_invoices.length}', false);
    _genListener.onPhaseComplete(_invoices.length);
    return null;
  }

  static Future _processInvoiceAcceptances() async {
    if (_invoices.isEmpty) {
      _invoices = await ListAPI.getAllInvoices();
    }
    var rem = _invoices.length % PAGE_SIZE;
    var pages = _invoices.length ~/ PAGE_SIZE;
    if (rem > 0) {
      pages++;
    }

    _invoiceAcceptances = List();
    index = 0;
    for (var i = 0; i < pages; i++) {
      List<InvoiceAcceptance> accList = List();
      for (var j = 0; j < PAGE_SIZE; j++) {
        try {
          var invoice = _invoices.elementAt(index);
          var acceptance = InvoiceAcceptance(
              customerName: invoice.customerName,
              customer: invoice.customer,
              invoice: invoice.invoiceId,
              invoiceNumber: invoice.invoiceNumber,
              supplier: invoice.supplier,
              supplierName: invoice.supplierName);

          accList.add(acceptance);
          index++;
        } catch (e) {}
      }
      _genListener.onEvent(
          '🔖 🔖 sending ${accList.length} InvoiceAcceptances', false);
      var bag = APIBag(
          jsonString: JsonEncoder().convert(accList),
          functionName: CHAIN_ADD_INVOICE_ACCEPTANCE,
          userName: DataAPI3.TemporaryUserName);

      try {
        var replyFromWeb = await _sendMultipleChaincodeTransactions(bag);
        var result = replyFromWeb['result'];
        result.forEach((m) {
          _invoiceAcceptances.add(InvoiceAcceptance.fromJson(m));
        });
      } catch (e) {
        print('\n\n👿  👿  👿  👿  👿  👿  👿  👿 ');
        print(e);
      }
    }
    _genListener.onEvent(
        '🔷 InvoiceAcceptances generated: 🔷 ${_invoiceAcceptances.length}',
        false);
    _genListener.onPhaseComplete(_invoiceAcceptances.length);
    return null;
  }

  static Future _processOffers() async {
    if (_invoiceAcceptances.isEmpty || _invoices.isEmpty) {
      _invoiceAcceptances = await ListAPI.getAllInvoiceAcceptances();
      _invoices = await ListAPI.getAllInvoices();
    }
    var rem = _invoiceAcceptances.length % PAGE_SIZE;
    var pages = _invoiceAcceptances.length ~/ PAGE_SIZE;
    if (rem > 0) {
      pages++;
    }
    print(
        '🚀 🚀 🚀  processing $pages pages * $PAGE_SIZE = ${PAGE_SIZE * pages} ish ... rem: $rem');
    _offers = List();
    index = 0;
    for (var i = 0; i < pages; i++) {
      List<Offer> offerList = List();
      for (var j = 0; j < PAGE_SIZE; j++) {
        double disc = _getRandomDisc();
        var sector = _sectors.elementAt(rand.nextInt(_sectors.length - 1));
        assert(sector != null);
        try {
          InvoiceAcceptance acceptance = _invoiceAcceptances.elementAt(index);
          Invoice invoice;
          _invoices.forEach((i) {
            if (i.invoiceId == acceptance.invoice) {
              invoice = i;
            }
          });
          Offer offer = new Offer(
              supplier: invoice.supplier,
              invoice: invoice.invoiceId,
              purchaseOrder: invoice.purchaseOrder,
              offerAmount: invoice.amount * ((100 - disc) / 100),
              invoiceAmount: invoice.totalAmount,
              discountPercent: disc,
              startTime: getUTCDate(),
              endTime: _getRandomEndDate(),
              participantId: invoice.supplier,
              customerName: invoice.customerName,
              supplierName: invoice.supplierName,
              sectorName: sector.sectorName,
              customer: invoice.customer,
              sector: sector.sectorId,
              invoiceAcceptance: acceptance.acceptanceId);
          offerList.add(offer);
          index++;
        } catch (e) {}
      }
      _genListener.onEvent(
          '🛎 🛎 sending ${offerList.length} offers, page: ${i + 1}', false);
      var bag = APIBag(
          jsonString: JsonEncoder().convert(offerList),
          functionName: CHAIN_ADD_OFFER,
          userName: DataAPI3.TemporaryUserName);

      var replyFromWeb = await _sendMultipleChaincodeTransactions(bag);
      var result = replyFromWeb['result'];
      result.forEach((m) {
        _offers.add(Offer.fromJson(m));
      });
    }
    _genListener.onEvent('🛎 🛎 offers generated: ${_offers.length}', false);
    _genListener.onPhaseComplete(_offers.length);
    return null;
  }

  static Future<Map> _sendMultipleChaincodeTransactions(APIBag bag) async {
    var url = getMultipleTransactionsUrl();
    print(
        '\n\n🔵 🔵 🔵 🔵 🔵 🔵  _sendMultipleChaincodeTransactions; sending: 🚀 🚀  $url \n🔵 🔵 🔵 🔵 🔵 🔵  '
        '${json.encode(bag.toJson())} \n🔵 🔵 🔵 🔵 🔵 🔵 ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(url));
      mRequest.headers.contentType = DataAPI3.contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          '\n\n🔵 🔵 🔵 🔵 🔵 🔵 _sendMultipleChaincodeTransactions blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        // transforms and prints the response
        String reply = await mResponse.transform(utf8.decoder).join();
        print(
            '🔵 🔵 🔵  🔵 🔵 🔵  🔵 🔵 🔵  🔵 🔵 🔵  reply  ..............\n$reply');
        Map map = JsonDecoder().convert(reply);
        prettyPrint(map, '🔆 🔆 REPLY OBJECT: check statusCode and result ...');
        print(
            '\n🔵 🔵 🔵  🔵 🔵 🔵  end of result object, is a Map? : ${map['result'] is Map}  🔵 🔵 🔵  🔵 🔵 🔵 \n');
        if (map['statusCode'] == 200) {
          return map;
        } else {
          throw Exception(map['message']);
        }
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print(
              '\n\n😡 😡 😡 😡 _sendMultipleChaincodeTransactions  $contents');
        });
        print(
            '\n\n😡 😡 😡 😡  _sendMultipleChaincodeTransactions ERROR  ${mResponse.reasonPhrase}');
        throw Exception(mResponse.reasonPhrase);
      }
    } catch (e) {
      print(
          '\n\n👿 👿 👿  👿 👿 👿  _sendMultipleChaincodeTransactions; ERROR : \n$e \n\n👿 👿 👿 👿 👿 👿 ');
      throw e;
    }
  }

  static String _getRandomEndDate() {
    int days = rand.nextInt(20);
    if (days < 10) {
      days = 10;
    }
    var date = DateTime.now().add(Duration(days: days));
    return getUTC(date);
  }

  static double _getRandomDisc() {
    const discounts = [
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      1.0,
      2.0,
      3.0,
      7.0,
      8.0,
      4.0,
      5.0,
      9.0,
      2.0,
      1.0,
      3.0,
      4.0,
      10.0,
      4.0,
      11.0,
      1.0,
      2.0,
      5.0,
      3.0,
      12.0
    ];
    return discounts[rand.nextInt(discounts.length - 1)];
  }

  static double _getRandomMinimumDisc() {
    const discounts = [
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      1.0,
      2.0,
      3.0,
      8.0,
      4.0,
      5.0,
      9.0,
      2.0,
      1.0,
      3.0,
      4.0,
      4.0,
      1.0,
      2.0,
      5.0,
      3.0,
    ];
    return discounts[rand.nextInt(discounts.length - 1)];
  }

  static String _getRandomPO() {
    var po =
        'PO-${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}';
    po += '-${rand.nextInt(9)}${rand.nextInt(9)}';
    return po;
  }

  static String _getRandomInvoiceNumber() {
    var po =
        'INV-${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}';
    po += '-${rand.nextInt(9)}${rand.nextInt(9)}';
    return po;
  }

  static double _getRandomPOAmount() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(100) * 6950.00;
    } else {
      seed = rand.nextInt(100) * 765.00;
    }
    if (seed == 0.0) {
      seed = 100000.00;
    }
    return seed;
  }

  static double _getRandomMaxInvestable() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(100) * 695000.00;
    } else {
      seed = rand.nextInt(100) * 76500.00;
    }
    if (seed == 0.0) {
      seed = 5000000.00;
    }
    return seed;
  }

  static double _getRandomMaxInvoice() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(1000) * 695.00;
    } else {
      seed = rand.nextInt(1000) * 765.00;
    }
    if (seed == 0.0) {
      seed = 500000.00;
    }
    return seed;
  }
}

class Unit {
  Customer customer;
  Supplier supplier;

  Unit(this.customer, this.supplier);
}
