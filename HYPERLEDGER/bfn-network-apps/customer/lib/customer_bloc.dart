import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class CustomerModelBlocListener {
  onEvent(String message);
}

class CustomerBloc implements CustomerBlocListener {
  final StreamController<CustomerApplicationModel> _appModelController =
      StreamController.broadcast();
  final StreamController<String> _errorController = StreamController<String>();
  final CustomerApplicationModel _appModel = CustomerApplicationModel();
  final StreamController<String> _fcmMessageController =
      StreamController.broadcast();

  CustomerBloc() {
    print(
        '\n\n 🔵  🔵  🔵  🔵  🔵 CustomerModelBloc - CONSTRUCTOR - ✈️ ✈️ ✈️ ✈️  set listener and 🍏 🍎 initialize app model');
    _appModel.setListener(this);
    initialize();
  }

  fixUsers() async {
    print('🔵  🔵  🔵  🔵  🔵 fix Users - ️ 🔧️ 🔧️ 🔧️ 🔧 create Auth users');
    Firestore fs = Firestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var qs = await fs.collection('users').getDocuments();
    var cnt = 0;
    for (var doc in qs.documents) {
      var user = User.fromJson(doc.data);
      await auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);
      cnt++;
      print(
          '❤️ 🧡 💛 💚 💙 💜 Firebase Auth user 🌺 #$cnt created: ${user.firstName} ${user.lastName} ${user.userId}');
    }
  }

  initialize() async {
    await _appModel.initialize();
    _appModelController.sink.add(_appModel);

    print('🔵  🔵  🔵  🔵  🔵 App Model completed initialization 🎈 🎈');
  }

  get appModel => _appModel;
  get fcmStream => _fcmMessageController.stream;
  receivePurchaseOrderMessage(PurchaseOrder order, BuildContext ctx) {
    print('☘ ☘ ☘ po arrived at Bloc receivePurchaseOrderMessage  ☘');
    var msg =
        '🔆 Purchase Order arrived:  ${getFormattedAmount('${order.amount}', ctx)} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  receiveDeliveryNoteMessage(DeliveryNote note, BuildContext ctx) {
    var msg =
        '☘  Delivery Note arrived:  ${getFormattedAmount('${note.totalAmount}', ctx)} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  receiveDeliveryAcceptanceMessage(
      DeliveryAcceptance acceptance, BuildContext ctx) {
    var msg =
        '🔆 Delivery Acceptance arrived:  ${acceptance.customerName} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  receiveInvoiceMessage(Invoice invoice, BuildContext ctx) {
    var msg =
        '🔆 Invoice arrived:  ${getFormattedAmount('${invoice.amount}', ctx)} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  receiveInvoiceAcceptanceMessage(
      InvoiceAcceptance acceptance, BuildContext ctx) {
    var msg =
        '🔆 Invoice Acceptance arrived:  ${acceptance.invoiceNumber} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  refreshModel() async {
    await _appModel.refreshModel();
    _appModelController.sink.add(_appModel);
  }

  refreshSettlements() async {
    await _appModel.refreshInvestorSettlements();
    _appModelController.sink.add(_appModel);
  }

  refreshPurchaseOrders() async {
    await _appModel.refreshPurchaseOrders();
    _appModelController.sink.add(_appModel);
  }

  refreshDeliveryNotes() async {
    await _appModel.refreshDeliveryNotes();
    _appModelController.sink.add(_appModel);
  }

  refreshDeliveryAcceptances() async {
    await _appModel.refreshDeliveryAcceptances();
    _appModelController.sink.add(_appModel);
  }

  refreshInvoices() async {
    await _appModel.refreshInvoices();
    _appModelController.sink.add(_appModel);
  }

  refreshInvoiceAcceptances() async {
    await _appModel.refreshInvoiceAcceptances();
    _appModelController.sink.add(_appModel);
  }

  refreshOffers() async {
    await _appModel.refreshOffers();
    _appModelController.sink.add(_appModel);
  }

  closeStream() {
    _appModelController.close();
    _errorController.close();
    _fcmMessageController.close();
  }

  get appModelStream => _appModelController.stream;

  @override
  onComplete() {
    print(
        '\n\n✅ CustomerModelBloc.onComplete ########## adding model to stream sink ......... ');
    _appModelController.sink.add(_appModel);
  }

  @override
  onError(String message) {
    _errorController.sink.add(message);
  }
}

final customerBloc = CustomerBloc();

abstract class CustomerBlocListener {
  onComplete();
  onError(String message);
}

class CustomerApplicationModel {
  List<DeliveryNote> _deliveryNotes = List();
  List<PurchaseOrder> _purchaseOrders = List();
  List<Invoice> _invoices = List();
  List<DeliveryAcceptance> _deliveryAcceptances = List();
  List<Offer> _offers = List();
  List<InvoiceBid> _unsettledInvoiceBids = List();
  List<InvoiceBid> _settledInvoiceBids = List();
  List<InvestorInvoiceSettlement> _settlements = List();
  List<InvoiceAcceptance> _invoiceAcceptances = List();
  Customer _customer;
  User _user;
  CustomerBlocListener _listener;

  List<DeliveryNote> get deliveryNotes => _deliveryNotes;
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  List<Invoice> get invoices => _invoices;
  List<DeliveryAcceptance> get deliveryAcceptances => _deliveryAcceptances;
  List<Offer> get offers => _offers;
  List<InvoiceBid> get unsettledInvoiceBids => _unsettledInvoiceBids;
  List<InvoiceBid> get settledInvoiceBids => _settledInvoiceBids;
  List<InvestorInvoiceSettlement> get settlements => _settlements;
  List<InvoiceAcceptance> get invoiceAcceptances => _invoiceAcceptances;
  Customer get customer => _customer;
  User get user => _user;
  CustomerBlocListener get listener => _listener;
  int _pageLimit = 10;
  int get pageLimit => _pageLimit;

  void setListener(CustomerBlocListener sbListener) {
    _listener = sbListener;
  }

  Future initialize() async {
    print(
        '\n\n✈️ ✈️ ✈️ ✈️  CustomerApplicationModel.initialize - 🎈 🎈 🎈  load model data from cache');
    var start = DateTime.now();
    _customer = await SharedPrefs.getCustomer();
    _user = await SharedPrefs.getUser();
    _pageLimit = await SharedPrefs.getPageLimit();
    if (_pageLimit == null) {
      _pageLimit = 10;
    }

    _purchaseOrders = await Database.getPurchaseOrders();
    _setItemNumbers(_purchaseOrders);

    if (_purchaseOrders != null)
      print(
          'CustomerApplicationModel.initialize, _purchaseOrders found in database: ${_purchaseOrders.length}');
    if (_purchaseOrders == null || _purchaseOrders.isEmpty) {
      refreshModel();
      return null;
    }
    print(
        '\n\nCustomerApplicationModel.initialize - ############### loading Model from cache ...');
    _deliveryNotes = await Database.getDeliveryNotes();
    _setItemNumbers(_deliveryNotes);

    _deliveryAcceptances = await Database.getDeliveryAcceptances();
    _setItemNumbers(_deliveryAcceptances);

    _invoices = await Database.getInvoices();
    _setItemNumbers(_invoices);

    _invoiceAcceptances = await Database.getInvoiceAcceptances();
    _setItemNumbers(_invoiceAcceptances);

    _offers = await Database.getOffers();
    _setItemNumbers(_offers);

    _unsettledInvoiceBids = await Database.getUnsettledInvoiceBids();
    _setItemNumbers(_unsettledInvoiceBids);

    _settlements = await Database.getInvestorInvoiceSettlements();
    _setItemNumbers(_settlements);

    var end = DateTime.now();
    print('\n\n🎈 🎈 🎈 🎈 CustomerApplicationModel.initialize '
        '🍏 🍎  model refreshed: elapsed time: '
        '🍏 🍎 ${end.difference(start).inMilliseconds} milliseconds. calling notifyListeners');
    return null;
  }

  double getTotalInvoiceValue() {
    if (_invoices == null) return 0.00;
    var t = 0.0;
    _invoices.forEach((i) {
      t += i.totalAmount;
    });
    return t;
  }

  double getTotalPurchaseOrderValue() {
    if (_purchaseOrders == null) return 0.00;
    var t = 0.0;
    _purchaseOrders.forEach((i) {
      t += i.amount;
    });
    return t;
  }

  void _setItemNumbers(List<Findable> list) {
    if (list == null) return;
    int num = 1;
    list.forEach((o) {
      o.itemNumber = num;
      num++;
    });
    _listener.onComplete();
  }

  Future addPurchaseOrder(PurchaseOrder order) async {
    _purchaseOrders.insert(0, order);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);
  }

  Future addDeliveryNote(DeliveryNote note) async {
    _deliveryNotes.insert(0, note);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
  }

  Future addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
  }

  Future addDeliveryAcceptance(DeliveryAcceptance acceptance) async {
    _deliveryAcceptances.insert(0, acceptance);
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
  }

  Future addInvoiceAcceptance(InvoiceAcceptance acceptance) async {
    _invoiceAcceptances.insert(0, acceptance);
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
  }

  Future addOffer(Offer offer) async {
    _offers.insert(0, offer);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
  }

  Future addInvestorInvoiceSettlement(
      InvestorInvoiceSettlement settlement) async {
    _settlements.insert(0, settlement);
    await Database.saveInvestorInvoiceSettlements(
        InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);
  }

  Future addUnsettledInvoiceBid(InvoiceBid bid) async {
    _unsettledInvoiceBids.insert(0, bid);
    await Database.saveUnsettledInvoiceBids(InvoiceBids(_unsettledInvoiceBids));
    _setItemNumbers(_unsettledInvoiceBids);
  }

  int getTotalOpenOffers() {
    var tot = 0;
    _offers.forEach((o) {
      if (o.isOpen) {
        tot++;
      }
    });
    return tot;
  }

  double getTotalOpenOfferAmount() {
    var tot = 0.0;
    _offers.forEach((o) {
      if (o.isOpen) {
        tot += o.offerAmount;
      }
    });
    return tot;
  }

  double getTotalDeliveryNoteAmount() {
    var tot = 0.0;
    _deliveryNotes.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  int getTotalClosedOffers() {
    var tot = 0;
    _offers.forEach((o) {
      if (o.isOpen == false) {
        tot++;
      }
    });
    return tot;
  }

  double getTotalClosedOfferAmount() {
    var tot = 0.0;
    _offers.forEach((o) {
      if (o.isOpen == false) {
        tot += o.offerAmount;
      }
    });
    return tot;
  }

  int getTotalCancelledOffers() {
    var tot = 0;
    _offers.forEach((o) {
      if (o.isCancelled) {
        tot++;
      }
    });
    return tot;
  }

  double getTotalSettlementValue() {
    var tot = 0.00;
    _settlements.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  double getTotalCancelledOfferAmount() {
    var tot = 0.0;
    _offers.forEach((o) {
      if (o.isCancelled) {
        tot += o.offerAmount;
      }
    });
    return tot;
  }

  double getTotalInvoiceAmount() {
    var tot = 0.00;
    _invoices.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  int getTotalInvoices() {
    return _invoices.length;
  }

  int getTotalPurchaseOrders() {
    return _purchaseOrders.length;
  }

  double getTotalPurchaseOrderAmount() {
    var tot = 0.0;
    _purchaseOrders.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  int getTotalSettlements() {
    return _settlements.length;
  }

  double getTotalSettlementAmount() {
    var tot = 0.0;
    _settlements.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  Future updatePageLimit(int pageLimit) async {
    _pageLimit = pageLimit;
    await SharedPrefs.savePageLimit(pageLimit);
    return null;
  }

  Future refreshInvestorSettlements() async {
    if (_customer == null) {
      _customer = await SharedPrefs.getCustomer();
      _user = await SharedPrefs.getUser();
    }
    if (_customer == null) return null;
    _settlements =
        await ListAPI.getCustomerInvestorSettlements(_customer.participantId);
    await Database.saveInvestorInvoiceSettlements(
        InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);
  }

  Future refreshPurchaseOrders() async {
    if (_customer == null) {
      _customer = await SharedPrefs.getCustomer();
      _user = await SharedPrefs.getUser();
    }
    if (_customer == null) return null;
    _purchaseOrders =
        await ListAPI.getCustomerPurchaseOrders(_customer.participantId);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);
  }

  static const CUSTOMER_TYPE = 'customer';
  Future refreshModel() async {
    if (_customer == null) {
      _customer = await SharedPrefs.getCustomer();
      _user = await SharedPrefs.getUser();
    }
    if (_customer == null) return null;
    print(
        'CustomerApplicationModel.refreshModel - get fresh data from Firestore');
    var start = DateTime.now();
    _purchaseOrders =
        await ListAPI.getCustomerPurchaseOrders(_customer.participantId);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);

    _deliveryNotes = await ListAPI.getDeliveryNotes(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
    print('\n\n');

    _invoices = await ListAPI.getCustomerInvoices(_customer.participantId);
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
    print('\n\n');

    _offers = await ListAPI.getOffersByCustomer(_customer.participantId);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
    print('\n\n');

    _deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
    print('\n\n');

    _invoiceAcceptances = await ListAPI.getInvoiceAcceptances(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
    print('\n\n');

    _settlements =
        await ListAPI.getCustomerInvestorSettlements(_customer.participantId);
    await Database.saveInvestorInvoiceSettlements(
        InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);

    var end = DateTime.now();
    print(
        '\n\nCustomerApplicationModel.refreshModel ############ Refresh Complete, elapsed: ${end.difference(start).inSeconds} seconds');
    if (_listener != null) {
      _listener.onComplete();
    }
    return 0;
  }

  Future refreshModelWithListener(
      CustomerModelBlocListener refreshListener) async {
    if (_customer == null) {
      _customer = await SharedPrefs.getCustomer();
      _user = await SharedPrefs.getUser();
    }
    if (_customer == null) return null;
    print(
        'CustomerApplicationModel.refreshModel - get fresh data from Firestore');
    var start = DateTime.now();
    _purchaseOrders =
        await ListAPI.getCustomerPurchaseOrders(_customer.participantId);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);
    refreshListener
        .onEvent('Purchase Orders loaded: ${_purchaseOrders.length}');

    _deliveryNotes = await ListAPI.getDeliveryNotes(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
    refreshListener.onEvent('Delivery Notes loaded: ${_deliveryNotes.length}');
    print('\n\n');

    _invoices = await ListAPI.getCustomerInvoices(_customer.participantId);
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
    refreshListener.onEvent('Invoices loaded: ${_invoices.length}');
    print('\n\n');

    _offers = await ListAPI.getOffersByCustomer(_customer.participantId);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
    refreshListener.onEvent('Offers loaded: ${_offers.length}');
    print('\n\n');

    _deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
    refreshListener
        .onEvent('Delivery Acceptances loaded: ${_deliveryAcceptances.length}');
    print('\n\n');

    _invoiceAcceptances = await ListAPI.getInvoiceAcceptances(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
    refreshListener
        .onEvent('Invoice Acceptances loaded: ${_invoiceAcceptances.length}');
    print('\n\n');

    _settlements =
        await ListAPI.getCustomerInvestorSettlements(_customer.participantId);
    await Database.saveInvestorInvoiceSettlements(
        InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);
    refreshListener.onEvent('Settlementsloaded: ${_settlements.length}');

    var end = DateTime.now();
    print(
        '\n\nCustomerApplicationModel.refreshModel ############ Refresh Complete, elapsed: ${end.difference(start).inSeconds} seconds');
    if (_listener != null) {
      _listener.onComplete();
    }
    return 0;
  }

  Future refreshOffers() async {
    _offers = await ListAPI.getOffersByCustomer(_customer.participantId);
    _setItemNumbers(_offers);
    await Database.saveOffers(Offers(_offers));
  }

  Future refreshDeliveryNotes() async {
    _deliveryNotes = await ListAPI.getDeliveryNotes(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    _setItemNumbers(_deliveryNotes);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
  }

  Future refreshInvoices() async {
    _invoices = await ListAPI.getCustomerInvoices(_customer.participantId);
    _setItemNumbers(_invoices);
    await Database.saveInvoices(Invoices(_invoices));
  }

  Future refreshDeliveryAcceptances() async {
    _deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    _setItemNumbers(_deliveryAcceptances);
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
  }

  Future refreshInvoiceAcceptances() async {
    _invoiceAcceptances = await ListAPI.getInvoiceAcceptances(
        participantId: _customer.participantId, participantType: CUSTOMER_TYPE);
    _setItemNumbers(_invoiceAcceptances);
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
  }
}
