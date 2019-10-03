import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/country.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor-unsettled-summary.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/constants.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ListAPI {
  static final Firestore _firestore = Firestore.instance;
  static Future<AutoTradeStart> getAutoTradeStart() async {
    AutoTradeStart start;
    var qs = await _firestore
        .collection('autoTradeStarts')
        .orderBy('dateEnded', descending: true)
        .limit(1)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeStart $e');
      return null;
    });
    print('ListAPI.getAutoTradeStart found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    start = AutoTradeStart.fromJson(qs.documents.first.data);

    return start;
  }

  static Future<Wallet> getWallet({String participantId}) async {
    var qs = await _firestore
        .collection('wallets')
        .where('participantId', isEqualTo: participantId)
        .getDocuments();
    Wallet wallet = Wallet.fromJson(qs.documents.first.data);

    if (wallet.secret == null) {
      var decrypted =
          await decrypt(wallet.stellarPublicKey, wallet.encryptedSecret);
      wallet.secret = decrypted;
    }
    await SharedPrefs.saveWallet(wallet);
    return wallet;
  }

  static Future<List<User>> getGovtUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.customer != null) {
        list.add(user);
      }
    });
    print('ListAPI.getGovtUsers found: ${list.length} ');
    return list;
  }

  static Future<List<Country>> getCountries() async {
    List<Country> list = List();
    var qs = await _firestore.collection('countries').getDocuments();
    qs.documents.forEach((docSnap) {
      list.add(Country.fromJson(docSnap.data));
    });
    return list;
  }

  static Future<List<User>> getInvestorUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.investor != null) {
        list.add(user);
      }
    });
    print('ListAPI.getInvestorUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getSupplierUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.supplier != null) {
        list.add(user);
      }
    });
    print('ListAPI.getSupplierUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getUsers() async {
    List<User> list = List();
    var qs =
        await _firestore.collection('users').getDocuments().catchError((e) {
      print('ListAPI.getUsers $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new User.fromJson(doc.data));
    });

    print(
        '❤️ ❤️ ❤️  ListAPI.getUsers ########## found in list: ${list.length} ');
    return list;
  }

  static Future<OfferBag> getOfferWithBids(String offerId) async {
    List<InvoiceBid> list = List();
    OfferBag bag;

    var qs = await _firestore
        .collection(FS_OFFERS)
        .where('offerId', isEqualTo: offerId)
        .getDocuments();
    Offer offer;
    if (qs.documents.isNotEmpty) {
      offer = Offer.fromJson(qs.documents.elementAt(0).data);
    }

    var snap = await _firestore
        .collection('invoiceBids')
        .where('offer', isEqualTo: offerId)
        .getDocuments();

    snap.documents.forEach((doc) {
      var bid = InvoiceBid.fromJson(doc.data);
      list.add(bid);
    });

    print('ListAPI.getInvoiceBidsByOffer found ${list.length} invoice bids');
    bag = OfferBag(offer: offer, invoiceBids: list);

    return bag;
  }

  static Future<InvoiceAcceptance> getLastInvoiceAcceptance(
      String supplierDocRef) async {
    InvoiceAcceptance acceptance;

    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocRef)
        .collection('invoiceAcceptances')
        .orderBy('date', descending: true)
        .limit(1)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getLastInvoiceAcceptance $e');
      return acceptance;
    });
    if (qs.documents.isNotEmpty) {
      acceptance = InvoiceAcceptance.fromJson(qs.documents.first.data);
    }
    if (acceptance != null) {
      print('ListAPI.getLastInvoiceAcceptance found ${acceptance.toJson()}');
    }
    return acceptance;
  }

  static Future<InvoiceAcceptance> getInvoiceAcceptanceByInvoice(
      String invoiceId) async {
    InvoiceAcceptance acceptance;

    var qs = await _firestore
        .collection('invoiceAcceptances')
        .where('invoice', isEqualTo: invoiceId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return acceptance;
    });
    if (qs.documents.isNotEmpty) {
      acceptance = InvoiceAcceptance.fromJson(qs.documents.first.data);
    }
    if (acceptance != null) {
      print(
          'ListAPI.getInvoiceAcceptanceByInvoice found ${acceptance.toJson()}');
    }
    return acceptance;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByOffer(String offerId) async {
    List<InvoiceBid> list = List();
    print(
        '\n\n\nListAPI.getInvoiceBidsByOffer ....................... start query: $offerId');
    var start = DateTime.now();
    var qs = await _firestore
        .collection('invoiceBids')
        .where('offer', isEqualTo: offerId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return list;
    });
    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        var bid = InvoiceBid.fromJson(doc.data);
        list.add(bid);
      });
      var end = DateTime.now();
      var diff = end.difference(start).inSeconds;
      print(
          'ListAPI.getInvoiceBidsByOffer ############# found ${list.length} invoice bids. elapsed: $diff seconds');
      return list;
    }

    return list;
  }

  static Future<List<InvoiceBid>> getUnsettledInvoiceBidsByInvestor(
      String participantId) async {
    print(
        '\n\n\nListAPI.getUnsettledInvoiceBidsByInvestor ========= investor : $participantId');
    var start = DateTime.now();
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceBids')
        .where('isSettled', isEqualTo: false)
        .where('investor', isEqualTo: participantId)
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getUnsettledInvoiceBidsByInvestor $e');
      return list;
    });

    var end = DateTime.now();
    print(
        'ListAPI.getUnsettledInvoiceBidsByInvestor -------------> found: ${qs.documents.length} elapsed: ${end.difference(start).inSeconds} seconds\n\n');

    qs.documents.forEach((doc) {
      var bid = InvoiceBid.fromJson(doc.data);
      if (bid.isSettled == false) {
        list.add(bid);
      }
    });
    return list;
  }

  static Future<List<InvoiceBid>> getSettledInvoiceBidsByInvestor(
      String participantId) async {
    var start = DateTime.now();
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceBids')
        .where('isSettled', isEqualTo: true)
        .where('investor', isEqualTo: participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSettledInvoiceBidsByInvestor $e');
      return list;
    });

    var end = DateTime.now();
    print(
        'ListAPI.getSettledInvoiceBidsByInvestor -----------> found: ${qs.documents.length} '
        'elapsed: ${end.difference(start).inSeconds} seconds\n\n');

    qs.documents.forEach((doc) {
      var bid = InvoiceBid.fromJson(doc.data);
      if (bid.isSettled == true) {
        list.add(bid);
      }
    });

    return list;
  }

  static Future<List<InvestorInvoiceSettlement>> getSettlementsByInvestor(
      String participantId) async {
    var start = DateTime.now();
    List<InvestorInvoiceSettlement> list = List();
    var qs = await _firestore
        .collection('settlements')
        .where('investor', isEqualTo: participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSettlementsByInvestor $e');
      return list;
    });

    var end = DateTime.now();
    print(
        'ListAPI.getSettlementsByInvestor -----------> found: ${qs.documents.length} '
        'elapsed: ${end.difference(start).inSeconds} seconds\n\n');

    qs.documents.forEach((doc) {
      var bid = InvestorInvoiceSettlement.fromJson(doc.data);
      list.add(bid);
    });

    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidByInvestorOffer(
      {Offer offer, Investor investor}) async {
    print(
        'ListAPI.getInvoiceBidByInvestorOffer =======> offer: ${offer.offerId} '
        'offer.offerId: ${offer.offerId} participantId: ${investor.participantId}');
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceBids')
        .where('offer', isEqualTo: offer.offerId)
        .where('investor', isEqualTo: investor.participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceBidByInvestorOffer $e');
      return list;
    });

    print(
        'ListAPI.getInvoiceBidByInvestorOffer ######## found: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      print(
          'ListAPI.getInvoiceBidByInvestorOffer: qs.documents isEmpty ----------');
    } else {
      print(
          'ListAPI.getInvoiceBidByInvestorOffer - we have a document here!!!!!!!');
    }
    qs.documents.forEach((doc) {
      var invoiceBid = InvoiceBid.fromJson(doc.data);
      list.add(invoiceBid);
    });
    print(
        'ListAPI.getInvoiceBidByInvestorOffer ######## found objects: ${list.length} ');
    return list;
  }

  static Future<InvoiceBid> getInvoiceBidById({String invoiceBidId}) async {
    assert(invoiceBidId != null);
    print('ListAPI.getInvoiceBidById =======> id: $invoiceBidId');
    var docSnapshot = await _firestore
        .collection('invoiceBids')
        .document(invoiceBidId)
        .get()
        .catchError((e) {
      print('ListAPI.getInvoiceBidById $e');
      throw e;
    });

    if (docSnapshot.exists) {
      print('ListAPI.getInvoiceBidById ######## found: 1');
      var bid = InvoiceBid.fromJson(docSnapshot.data);
      return bid;
    } else {
      throw Exception('Invoice Bid not found');
    }
  }

  static Future<OfferBag> getOfferById(String offerId) async {
    print(
        '\n\n\nListAPI.getOfferByDocRef ............................... documentRef: $offerId');
    var start = DateTime.now();
    Offer offer;
    DocumentSnapshot qs = await _firestore
        .collection('offers')
        .document(offerId)
        .get()
        .catchError((e) {
      print('ListAPI.getOfferByDocRef $e');
      return null;
    });
    offer = Offer.fromJson(qs.data);
    var end1 = DateTime.now();
    print(
        'ListAPI.getOfferByDocRef offer found:  elapsed : ${end1.difference(start).inMilliseconds} milliseconds');
    prettyPrint(offer.toJson(), '############# OFFER: ... getting bids ...');
    var qs1 = await _firestore
        .collection('invoiceBids')
        .where('offerDocRef', isEqualTo: offerId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByDocRef $e');
      return null;
    });
    var end2 = DateTime.now();
    print(
        'ListAPI.getOfferByDocRef invoiceBids found: ${qs1.documents.length}  elapsed : ${end2.difference(end1).inMilliseconds} milliseconds');
    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print(
        'ListAPI.getOfferByDocRef built local invoice bids for offer: ${bids.length}. setting up bag ');
    var bag = OfferBag(offer: offer, invoiceBids: bids);
    return bag;
  }

  static Future<OfferBag> getOfferByOfferId(String offerId) async {
    print(
        '\n\n\nListAPI.getOfferById ............................... id: $offerId');
    var start = DateTime.now();
    Offer offer;
    QuerySnapshot qs = await _firestore
        .collection('offers')
        .where('offerId', isEqualTo: offerId)
        .limit(1)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferById $e');
      return null;
    });
    var end1 = DateTime.now();
    print(
        'ListAPI.getOfferById ############## found offer: ${qs.documents.length} elapsed : ${end1.difference(start).inMilliseconds} milliseconds ');

    if (qs.documents.isEmpty) {
      return OfferBag();
    }
    offer = Offer.fromJson(qs.documents.first.data);
    prettyPrint(offer.toJson(), '############# OFFER: ... getting bids ...');
    var qs1 = await _firestore
        .collection('invoiceBids')
        .where('offer', isEqualTo: offerId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferById $e');
      return null;
    });
    var end2 = DateTime.now();
    print(
        'ListAPI.getOfferById invoiceBids found: ${qs1.documents.length}  elapsed : ${end2.difference(end1).inMilliseconds} milliseconds');
    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print(
        'ListAPI.getOfferById built local invoice bids for offer: ${bids.length}. setting up bag ');
    var bag = OfferBag(offer: offer, invoiceBids: bids);
    return bag;
  }

  static Future<OfferBag> getOfferByInvoice(String invoiceId) async {
    Offer offer;
    var qs = await _firestore
        .collection('offers')
        .where('invoice', isEqualTo: invoiceId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByInvoice $e');
      return null;
    });
    print(
        'ListAPI.getOfferByInvoice ++++++++++++++++ found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    offer = Offer.fromJson(qs.documents.first.data);
    var qs1 = await _firestore
        .collection('invoiceBids')
        .where('offer', isEqualTo: offer.offerId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByInvoice $e');
      return null;
    });

    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print(
        'ListAPI.getOfferByInvoice @@@@@@@@@@@@@ found invoice bids: ${qs1.documents.length} ');

    var bag = OfferBag(offer: offer, invoiceBids: bids);
    bag.doPrint();
    return bag;
  }

  static Future<List<Offer>> getOffersByPeriod(
      DateTime startTime, DateTime endTime) async {
    print(
        'ListAPI.getOffersByPeriod startTime: ${startTime.toIso8601String()}  endTime: ${endTime.toIso8601String()}');
    List<Offer> list = List();
    var qs = await _firestore
        .collection('offers')
        .where('startTime', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('startTime', isLessThanOrEqualTo: endTime.toIso8601String())
        .orderBy('startTime', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOffersByPeriod $e');
      return list;
    });
    print('ListAPI.getOffersByPeriod found: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return list;
    }
    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersBySector(
      String sector, DateTime startTime, DateTime endTime) async {
    List<Offer> list = List();
    var qs = await _firestore
        .collection('offers')
        .where('date', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('date', isLessThanOrEqualTo: endTime.toIso8601String())
        .where('sector', isEqualTo: sector)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierOffers $e');
      return list;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersBySupplier(String participantId) async {
    print(
        'ListAPI.getOffersBySupplier ---------------supplierId: $participantId');
    List<Offer> list = List();
    var qs = await _firestore
        .collection('offers')
        .where('supplier', isEqualTo: participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOffersBySupplier $e');
      return list;
    });

    print('ListAPI.getOffersBySupplier found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersByCustomer(String participantId) async {
    print(
        'ListAPI.getOffersByCustomer ---------------supplierId: $participantId');
    List<Offer> list = List();
    var qs = await _firestore
        .collection('offers')
        .where('customer', isEqualTo: participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOffersByCustomer $e');
      return list;
    });

    print('ListAPI.getOffersByCustomer found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });

    return list;
  }

  static Future<List<InvestorInvoiceSettlement>> getSupplierInvestorSettlements(
      String supplierId) async {
    print(
        'ListAPI.getSupplierInvestorSettlements ---------------supplierId: $supplierId');
    List<InvestorInvoiceSettlement> list = List();
    var qs = await _firestore
        .collection('settlements')
        .where('supplier', isEqualTo: supplierId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierInvestorSettlements $e');
      return list;
    });

    for (var doc in qs.documents) {
      var s = InvestorInvoiceSettlement.fromJson(doc.data);
      list.add(s);
    }

    print(
        'ListAPI.getSupplierInvestorSettlements found: ${qs.documents.length} ');

    return list;
  }

  static Future<List<InvestorInvoiceSettlement>> getCustomerInvestorSettlements(
      String customerId) async {
    print(
        'ListAPI.getCustomerInvestorSettlements ---------------customerId: $customerId');
    List<InvestorInvoiceSettlement> list = List();
    var qs = await _firestore
        .collection('settlements')
        .where('customer', isEqualTo: customerId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getCustomerInvestorSettlements $e');
      return list;
    });

    for (var doc in qs.documents) {
      var s = InvestorInvoiceSettlement.fromJson(doc.data);
      list.add(s);
    }

    print(
        'ListAPI.getCustomerInvestorSettlements found: ${qs.documents.length} ');

    return list;
  }

  static Future<Offer> checkOfferByInvoice(String invoiceId) async {
    print('ListAPI.checkOfferByInvoice ---------------supplierId: $invoiceId');
    Offer offer;
    var qs = await _firestore
        .collection('offers')
        .where('invoice', isEqualTo: invoiceId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.checkOfferByInvoice $e');
      return offer;
    });

    print('ListAPI.checkOfferByInvoice found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      offer = Offer.fromJson(doc.data);
    });

    return offer;
  }

  static Future<List<Offer>> getOpenOffersBySupplier(String supplierId) async {
    List<Offer> list = List();
    var now = getUTCDate();
    var qs = await _firestore
        .collection('offers')
        .where('isOpen', isEqualTo: true)
        .where('supplier', isEqualTo: supplierId)
        .where('endTime', isGreaterThan: now)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOpenOffersBySupplier $e');
      return list;
    });

    print(
        'ListAPI.getOpenOffersBySupplier +++++++ open offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });

    return list;
  }

  static const int MAXIMUM_RECORDS_FROM_FIRESTORE = 200;
  static Future<List<Offer>> getOpenOffers() async {
    print(
        '\n\nListAPI.getOpenOffers ----------------- getting Firestore offers, limit: $MAXIMUM_RECORDS_FROM_FIRESTORE');
    var start = DateTime.now();
    List<Offer> list = List();
    var now = getUTCDate();
    var qs = await _firestore
        .collection('offers')
        .where('isOpen', isEqualTo: true)
        .where('endTime', isGreaterThan: now)
        .limit(MAXIMUM_RECORDS_FROM_FIRESTORE)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOpenOffers $e');
      return list;
    });

    print(
        'ListAPI.getOpenOffers +++++++ >>> offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });
    var end = DateTime.now();
    print(
        'ListAPI.getOpenOffers +++++++++++++++ complete - ${end.difference(start).inSeconds} elapsed seconds\n\n');

    return list;
  }

  static Future<List<Offer>> getOpenOffersViaFunctions() async {
    String mUrl = getChaincodeUrl() + 'queryOffers';
    Map map = {'limit': MAXIMUM_RECORDS_FROM_FIRESTORE, 'open': true};

    return _queryOffers(mUrl: mUrl, parameters: map);
  }

  static Future<List<Offer>> _queryOffers({String mUrl, Map parameters}) async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var start = DateTime.now();
    try {
      http
          .post(mUrl, body: json.encode(parameters))
          .then((http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        var end = DateTime.now();
        print(
            '\n\nListAPI._doOffersHTTP .... ################ Query via Cloud Functions: status: ${statusCode} '
            'for $mUrl - elapsed: ${end.difference(start).inSeconds} seconds');
        if (statusCode == 200) {
          Map<String, dynamic> m = json.decode(response.body);
          return _parseOffers(m);
        } else {
          throw Exception('_doOffersHTTP data query failed');
        }
      });
    } catch (e) {
      print('ListAPI._queryOffers ........ fell down, why?');
      print('ListAPI._doOffersHTTP $e');
      throw e;
    }
  }

  static List<Offer> _parseOffers(Map map) {
    List<Offer> offers = List();
    try {
      List list = map['data'];
      list.forEach((doc) {
        var offer = Offer.fromJson(doc);
        offers.add(offer);
      });
    } catch (e) {
      print('ListAPI._parseOffers ERROR ... ERROR');
      print(e);
    }
    return offers;
  }

  static Future<List<Offer>> getExpiredOffers() async {
    List<Offer> list = List();
    var now = getUTCDate();
    var qs = await _firestore
        .collection('offers')
        .where('isOpen', isEqualTo: true)
        .where('endTime', isLessThan: now)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getExpiredOffers $e');
      return list;
    });

    print(
        'ListAPI.getExpiredOffers ------- offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      list.add(offer);
    });

    return list;
  }

  ///check if auto trade is running
  static Future<bool> checkLatestAutoTradeStart() async {
    try {
      var qs = await _firestore
          .collection('autoTradeStarts')
          .where('dateEnded', isNull: true)
          .getDocuments()
          .catchError((e) {
        print('DataAPI.addAutoTradeStart ERROR adding to Firestore $e');
        return '0';
      });
      if (qs.documents.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('DataAPI.addAutoTradeStart ERROR $e');
      return false;
    }
  }

  static Future<List<PurchaseOrder>> getCustomerPurchaseOrders(
      String participantId) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('purchaseOrders')
        .where('customer', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getPurchaseOrders  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print(
        'ListAPI.getCustomerPurchaseOrders &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<List<PurchaseOrder>> getAllPurchaseOrders() async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('purchaseOrders')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAllPurchaseOrders  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print(
        'ListAPI.getCustomerPurchaseOrders 😡 😡 😡 😡  found: ${list.length} ');
    return list;
  }

  static Future<List<Invoice>> getCustomerInvoices(String participantId) async {
    List<Invoice> list = List();
    var querySnapshot = await _firestore
        .collection('invoices')
        .where('customer', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getCustomerInvoices  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new Invoice.fromJson(doc.data);
      list.add(m);
    });
    print('ListAPI.getCustomerInvoices &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<List<PurchaseOrder>> getSupplierPurchaseOrders(
      String participantId) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('purchaseOrders')
        .where('supplier', isEqualTo: participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierPurchaseOrders  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print(
        'ListAPI.getSupplierPurchaseOrders &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<DashboardData> getSupplierDashboardData(
      String supplierId, String documentId) async {
    print('ListAPI.getSupplierDashboardData ..........');

    try {
      DashboardData result = await _doDashboardHTTP(
          mUrl: getWebUrl() + 'getSupplierDashboard',
          participantId: supplierId);
      prettyPrint(result.toJson(), '### Supplier Dashboard Data:');
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Future<DashboardData> getInvestorDashboardData(
      String participantId) async {
    try {
      DashboardData result = await _doDashboardHTTP(
          mUrl: getWebUrl() + 'getInvestorDashboard',
          participantId: participantId);

      prettyPrint(result.toJson(), '\n\n🔆 🔆 🔆 🔆 🔆 returned dash ...');
      return result;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<DashboardData> getCustomerDashboardData(
      String participantId) async {
    DashboardData result = await _doDashboardHTTP(
        mUrl: getWebUrl() + 'getCustomerDashboard',
        participantId: participantId);
    prettyPrint(result.toJson(), '### Dashboard Data from function call:');
    return result;
  }

  static Future<OpenOfferSummary> getOpenOffersWithPaging(
      {int lastDate, int pageLimit}) async {
    OpenOfferSummary summary = await _doOpenOffersHTTP(
        getChaincodeUrl() + 'getOpenOffersWithPaging', lastDate, pageLimit);
    if (summary.offers != null) {
      print(
          'ListAPI.getOpenOffersWithPaging &&&&&&&&&&& found: ${summary.offers.length} \n\n');
    }
    return summary;
  }

  static Future<PurchaseOrderSummary> getSupplierPurchaseOrdersWithPaging(
      {int startKey, int pageLimit, String documentId}) async {
    PurchaseOrderSummary summary = await _doPurchaseOrderHTTP(
        mUrl: getChaincodeUrl() + 'getPurchaseOrdersWithPaging',
        date: startKey,
        pageLimit: pageLimit,
        collection: 'suppliers',
        documentId: documentId);

    return summary;
  }

  static Future<PurchaseOrderSummary> getCustomerPurchaseOrdersWithPaging(
      {int lastDate, int pageLimit, String documentId}) async {
    PurchaseOrderSummary summary = await _doPurchaseOrderHTTP(
        mUrl: getChaincodeUrl() + 'getPurchaseOrdersWithPaging',
        date: lastDate,
        pageLimit: pageLimit,
        collection: 'govtEntities',
        documentId: documentId);

    return summary;
  }

  static Future<PurchaseOrderSummary> getCustomerInvoicessWithPaging(
      {int lastDate, int pageLimit, String documentId}) async {
    PurchaseOrderSummary summary = await _doPurchaseOrderHTTP(
        mUrl: getChaincodeUrl() + 'getPurchaseOrdersWithPaging',
        date: lastDate,
        pageLimit: pageLimit,
        collection: 'govtEntities',
        documentId: documentId);

    return summary;
  }

  static Future<OpenOfferSummary> _doOpenOffersHTTP(
      String mUrl, int date, int pageLimit) async {
    OpenOfferSummary summary = OpenOfferSummary();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, dynamic> map;
    if (date != null) {
      map = {'date': date, 'pageLimit': pageLimit};
    } else {
      map = {'pageLimit': pageLimit};
    }
    print('ListAPI._doOpenOffersHTTP ------- parameters: $map');
    var start = DateTime.now();
    try {
      http.post(mUrl, body: json.encode(map)).then((http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        print(
            'ListAPI._doOpenOffersHTTP .... ## Query via Cloud Functions: status: $statusCode');
        if (statusCode == 200) {
          summary = OpenOfferSummary.fromJson(json.decode(response.body));
          print(
              'ListAPI._doOpenOffersHTTP summary, offers: ${summary.offers.length}');
        } else {
          print(response.body);
        }
      });
    } catch (e) {
      print('ListAPI._doOpenOffersHTTP $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI._doOpenOffersHTTP ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<PurchaseOrderSummary> _doPurchaseOrderHTTP(
      {String mUrl,
      int date,
      int pageLimit,
      String documentId,
      String collection}) async {
    PurchaseOrderSummary summary;

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, dynamic> map;
    if (date != null) {
      map = {
        'date': date,
        'pageLimit': pageLimit,
        'collection': collection,
        'documentId': documentId
      };
    } else {
      map = {
        'pageLimit': pageLimit,
        'collection': collection,
        'documentId': documentId
      };
    }
    print('ListAPI._doPurchaseOrderHTTP ------- parameters: $map');
    var start = DateTime.now();
    try {
      http.post(mUrl, body: json.encode(map)).then((http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        print(
            'ListAPI._doOpenOffersHTTP .... ## Query via Cloud Functions: status: $statusCode');
        if (response.statusCode == 200) {
          //print(resp.body);
          summary = PurchaseOrderSummary.fromJson(json.decode(response.body));
          print(
              'ListAPI._doPurchaseOrderHTTP summary,: ${summary.purchaseOrders.length} purchase orders found');
        } else {
          print(response.body);
        }
      });
    } catch (e) {
      print('ListAPI._doPurchaseOrderHTTP $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI._doPurchaseOrderHTTP ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<OpenOfferSummary> getOpenOffersSummary() async {
    OpenOfferSummary summary = OpenOfferSummary();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var mUrl = getChaincodeUrl() + 'getOpenOffersSummary';
    Map<String, dynamic> map;
    map = {'debug': isInDebugMode};

    var start = DateTime.now();
    try {
      http.post(mUrl, body: json.encode(map)).then((http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        print(
            'ListAPI.getOpenOffersSummary .... ## Query via Cloud Functions: status: ${response.statusCode}');
        if (response.statusCode == 200) {
          summary = OpenOfferSummary.fromJson(json.decode(response.body));
          print('ListAPI.getOpenOffersSummary summary: ${summary.toJson()}');
        } else {
          print(response.body);
          return summary;
        }
      });
    } catch (e) {
      print('ListAPI.getOpenOffersSummary $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI.getOpenOffersSummary ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<InvestorBidSummary> getInvestorBidSummary(
      String documentId) async {
    InvestorBidSummary summary;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var mUrl = getChaincodeUrl() + 'getInvestorsSummary';
    Map<String, dynamic> map;
    map = {'documentId': documentId};

    var start = DateTime.now();
    try {
      http.post(mUrl, body: json.encode(map)).then((http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        print(
            '\n\nListAPI.getInvestorBidSummary .... ## Query via Cloud Functions: status: ${response.statusCode} for $mUrl');
        if (response.statusCode == 200) {
          summary = InvestorBidSummary.fromJson(json.decode(response.body));
        } else {
          print(response.body);
        }
      });
    } catch (e) {
      print('ListAPI.getInvestorBidSummary $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI.getInvestorBidSummary ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<DashboardData> _doDashboardHTTP(
      {String mUrl, String participantId}) async {
    DashboardData dashboardData;
    var body = {'participantId': participantId};
    print(
        '🚗  🚗  🚗  _doDashboardHTTP: Sending $mUrl participantId: $participantId');
    var start = DateTime.now();

    try {
      http.Response response = await http.post(mUrl, body: body);
      final int statusCode = response.statusCode;
      var end = DateTime.now();
      print(
          '\n\n🍉  🍉  🍉   ListAPI._doDashboardHTTP .... ################ Query via Web Api: status: 🍀 '
          '${response.statusCode} for $mUrl - elapsed: ⌛ ⌛ ${end.difference(start).inSeconds} seconds');
      print('\n🍀 🍀 🍀 \n${response.body} \n🍀  🍀  🍀 ');
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }

      if (response.statusCode == 200) {
        dashboardData = DashboardData.fromJson(json.decode(response.body));
        prettyPrint(dashboardData.toJson(),
            '\n\n💊💊💊💊 -->   🍀  🍀 - RETURNING DATA: ..................');
        return dashboardData;
      } else {
        throw Exception('Dashboard data query failed');
      }
    } catch (e) {
      print('ListAPI._doDashboardHTTP $e');
      throw e;
    }
  }

  static Future<List<Invoice>> getInvoicesBySupplier(String supplier) async {
    print('🔵 🔵  ListAPI.getInvoices ............. supplier: $supplier');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection('invoices')
        .where('supplier', isEqualTo: supplier)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoices $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoices - no docs found');
      return list;
    }
    qs.documents.forEach((doc) {
      list.add(new Invoice.fromJson(doc.data));
    });

    if (list.isNotEmpty) {
      print(
          'ListAPI.getInvoices  ✅ found: ${list.length} from ${list.elementAt(0).supplierName}');
    }
    return list;
  }

  static Future<List<Invoice>> getAllInvoices() async {
    print('🔵 🔵  ListAPI.getAllInvoices ............. ');
    List<Invoice> list = List();
    var qs =
        await _firestore.collection('invoices').getDocuments().catchError((e) {
      print('ListAPI.getInvoices $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoices - no docs found');
      return list;
    }
    qs.documents.forEach((doc) {
      list.add(new Invoice.fromJson(doc.data));
    });

    if (list.isNotEmpty) {
      print('ListAPI.getAllInvoices  ✅ found: ${list.length} ');
    }
    return list;
  }

  static Future<List<InvoiceAcceptance>> getInvoiceAcceptances(
      {String participantId, String participantType}) async {
    print(
        '❤️  ❤️ ListAPI.getInvoiceAcceptances ............. participantId: $participantId');
    List<InvoiceAcceptance> list = List();
    var qs = await _firestore
        .collection('invoiceAcceptances')
        .where(participantType, isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceAcceptances $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoiceAcceptances - no docs found');
      return list;
    }
    qs.documents.forEach((doc) {
      list.add(new InvoiceAcceptance.fromJson(doc.data));
    });

    if (list.isNotEmpty) {
      print(
          'ListAPI.getInvoiceAcceptances ❤️  ❤️  ❤️  ❤️  found: ${list.length} for ${list.elementAt(0).supplierName}');
    }
    return list;
  }

  static Future<List<Invoice>> getInvoicesOpenForOffers(
      String participantId, String collection) async {
    print(
        'ListAPI.getInvoicesOpenForOffers ............. documentId: $participantId in $collection');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection('invoices')
        .where('supplier', isEqualTo: participantId)
        .where('isOnOffer', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(1000)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesOpenForOffers $e');
      return list;
    });

    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesOpenForOffers - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOpenForOffers ################## found: ${list.length}');
//    list.forEach((inv) {
//      prettyPrint(inv.toJson(),
//          'getInvoicesOpenForOffers INVOICE NUMBER: ${inv.invoiceNumber}');
//    });
    return list;
  }

  static Future<List<Invoice>> getInvoicesOnOffer(
      String documentId, String collection) async {
    print('ListAPI.getInvoicesOnOffer ............. documentId: $documentId');
    //type '(dynamic) => List<Invoice>' is not a subtype of type '(Object) => FutureOr<QuerySnapshot>'
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('offer', isGreaterThan: '')
//        .orderBy('date', descending: true)
        .limit(100)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesOnOffer $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesOnOffer - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOnOffer ################## found: ${list.length}');
    return list;
  }

  static Future<List<Invoice>> getInvoicesSettled(
      String documentId, String collection) async {
    print('ListAPI.getInvoicesSettled ............. documentId: $documentId');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('isSettled', isEqualTo: 'true')
        .orderBy('date', descending: true)
        .limit(1000)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesSettled $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesSettled - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOnOffer ################## found: ${list.length}');
    list.forEach((inv) {
      prettyPrint(inv.toJson(),
          'getInvoicesSettled INVOICE NUMBER: ${inv.invoiceNumber}');
    });
    return list;
  }

  static Future<Invoice> getInvoice(
      {String poNumber, String invoiceNumber}) async {
    print(
        'ListAPI.getInvoice ............. poNumber: $poNumber invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('invoices')
        .where('purchaseOrderNumber', isEqualTo: poNumber)
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoice $e');
      return null;
    });
    print('ListAPI.getInvoice ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
    }

    return invoice;
  }

  static Future<Invoice> getCustomerInvoiceById({String invoiceId}) async {
    print('ListAPI.getInvoiceById ............. invoiceId: $invoiceId ');
    Invoice invoice;
    var qs = await _firestore
        .collection('invoices')
        .where('invoiceId', isEqualTo: invoiceId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceById $e');
      throw e;
    });
    print('ListAPI.getInvoice ............. found: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
    }

    return invoice;
  }

  static Future<List<Invoice>> getInvoicesByPurchaseOrder(
      String purchaseOrderId, String supplier) async {
    print(
        '🍑 🍑 🍑 ListAPI.getInvoicesByPurchaseOrder ............. deliveryNoteId: $purchaseOrderId  ');
    List<Invoice> invoices = List();
    var qs = await _firestore
        .collection('invoices')
        .where('purchaseOrder', isEqualTo: purchaseOrderId)
        .where('supplier', isEqualTo: supplier)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesByPurchaseOrder $e');
      return invoices;
    });
    print(
        'ListAPI.getInvoicesByPurchaseOrder ............. 🍑 🍑 🍑 found: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        var invoice = Invoice.fromJson(doc.data);
        invoices.add(invoice);
      });
    }

    return invoices;
  }

  static Future<Invoice> getInvoiceByDeliveryNote(
      String deliveryNoteId, String participantId) async {
    print(
        '🥦 🥦 🥦 ListAPI.getInvoiceByDeliveryNote ............. deliveryNoteId: $deliveryNoteId  ');
    Invoice invoice;
    var qs = await _firestore
        .collection('invoices')
        .where('deliveryNote', isEqualTo: deliveryNoteId)
        .where('supplier', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceByDeliveryNote $e');
      return null;
    });
    print(
        'ListAPI.getInvoiceByDeliveryNote ............. 🥦 🥦 🥦 found: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
    }

    return invoice;
  }

  static Future<Invoice> getSupplierInvoiceByNumber(
      String invoiceNumber, String supplier) async {
    print(
        'ListAPI.getSupplierInvoiceByNumber .............  invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('invoices')
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .where('supplier', isEqualTo: supplier)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierInvoiceByNumber $e');
      return null;
    });
    print(
        'ListAPI.getSupplierInvoiceByNumber ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
    }

    return invoice;
  }

  static Future<Invoice> getInvoiceByNumber(
      String invoiceNumber, String govtDocumentRef) async {
    print(
        'ListAPI.getGovtInvoiceByNumber .............  invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('govtEntities')
        .document(govtDocumentRef)
        .collection('invoices')
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtInvoiceByNumber $e');
      return null;
    });
    print(
        'ListAPI.getGovtInvoiceByNumber ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
    }

    return invoice;
  }

  static Future<Offer> findOfferByInvoice(String invoice) async {
    var qs = await _firestore
        .collection('offers')
        .where('invoice', isEqualTo: invoice)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtInvoiceByNumber $e');
      return null;
    });
    if (qs.documents.isNotEmpty) {
      var offer = Offer.fromJson(qs.documents.first.data);
      return offer;
    } else {
      return null;
    }
  }

  static Future<List<DeliveryNote>> getDeliveryNotes(
      {String participantId, String participantType}) async {
    print('ListAPI.getDeliveryNotes .......  documentId: $participantId');
    List<DeliveryNote> list = List();
    var qs = await _firestore
        .collection('deliveryNotes')
        .where(participantType, isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNotes $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryNote.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
  }

  static Future<List<DeliveryNote>> getAllDeliveryNotes() async {
    print('\n🔵 🔵 🔵  ListAPI.getAllDeliveryNotes .......\n');
    List<DeliveryNote> list = List();
    var qs = await _firestore
        .collection(FS_DELIVERY_NOTES)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAllDeliveryNotes $e');
      return list;
    });

    print(
        '\n💦  💦  💦  ############ getAllDeliveryNotes snapshot: ${qs.documents.length}');
    qs.documents.forEach((doc) {
      list.add(new DeliveryNote.fromJson(doc.data));
    });

    print('\n😡 😡 😡  ListAPI.getAllDeliveryNotes : found: ${list.length}');
    return list;
  }

  static Future<List<DeliveryAcceptance>> getAllDeliveryAcceptances() async {
    print('\n🏮 🏮 🏮   ListAPI.getAllDeliveryAcceptances .......');
    List<DeliveryAcceptance> list = List();
    var qs = await _firestore
        .collection(FS_DELIVERY_ACCEPTANCES)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptances  $e');
      return list;
    });

    print(
        '\n💦  💦  💦  ############ getAllDeliveryAcceptances snapshot: ${qs.documents.length}');
    qs.documents.forEach((doc) {
      list.add(new DeliveryAcceptance.fromJson(doc.data));
    });

    print(
        '\n🏮 🏮 🏮   ListAPI.getAllDeliveryAcceptances ############ found: ${list.length}');
    return list;
  }

  static Future<List<InvoiceAcceptance>> getAllInvoiceAcceptances() async {
    print(' 🔵 🔵 🔵  ListAPI.getAllInvoiceAcceptances .......');
    List<InvoiceAcceptance> list = List();
    var qs = await _firestore
        .collection('invoiceAcceptances')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAllInvoiceAcceptances  $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new InvoiceAcceptance.fromJson(doc.data));
    });

    print(
        ' 🔵 🔵 🔵  ListAPI.getAllInvoiceAcceptances ############ found: ${list.length}');
    return list;
  }

  static Future<DeliveryNote> getDeliveryNoteById(
      {String deliveryNoteId}) async {
    print(
        'ListAPI.getDeliveryNoteById .......  deliveryNoteId: $deliveryNoteId');
    DeliveryNote dn;
    var qs = await _firestore
        .collection('deliveryNotes')
        .where('deliveryNoteId', isEqualTo: deliveryNoteId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNoteById $e');
      return dn;
    });

    if (qs.documents.isNotEmpty) {
      dn = DeliveryNote.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryNoteById ############ found: ${qs.documents.length}');
    return dn;
  }

  static Future<Customer> getSupplierById(String participantId) async {
    Customer supplier;
    var qs = await _firestore
        .collection('suppliers')
        .where('participantId', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNoteById $e');
      return supplier;
    });

    if (qs.documents.isNotEmpty) {
      supplier = Customer.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryNoteById ############ found: ${qs.documents.length}');
    return supplier;
  }

  static Future<List<SupplierContract>> getSupplierContracts(
      String participantId) async {
    print('ListAPI.getSupplierContracts .......  documentId: $participantId');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(participantId)
        .collection('supplierContracts')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print('ListAPI.getSupplierContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<ChatMessage>> getChatMessages(String userId) async {
    List<ChatMessage> chatMessages = List();
    var qs = await _firestore
        .collection('chatMessages')
        .document(userId)
        .collection('messages')
        .limit(3)
        .orderBy('date', descending: true)
        .getDocuments();

    for (var doc in qs.documents) {
      var chatMsg = ChatMessage.fromJson(doc.data);
      chatMsg.responses = List();
      var qs2 = await doc.reference.collection('responses').getDocuments();
      print(
          'ChatWindow._getMessages ........ responses: ${qs2.documents.length}');
      qs2.documents.forEach((rdoc) {
        chatMsg.responses.add(ChatResponse.fromJson(rdoc.data));
      });
      chatMessages.add(chatMsg);
    }
    return chatMessages;
  }

  static Future<List<Customer>> getCustomersByCountry({String country}) async {
    if (country == null) {
      country = 'ZA';
    }
    print(
        '\n 🔵 🔵 🔵  ListAPI.getCustomersByCountry .......  country: $country');
    List<Customer> list = List();
    var qs = await _firestore
        .collection('customers')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('\n😡 😡 😡 😡   ListAPI.getCustomersByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      var m = Customer.fromJson(doc.data);
      list.add(m);
    });

    print('ListAPI.getGovtEntities ############ found: ${list.length}');
    return list;
  }

  static Future<List<Supplier>> getSuppliersByCountry({String country}) async {
    if (country == null) {
      country = 'ZA';
    }
    print(
        '\n🔵 🔵 🔵 ListAPI.getSuppliersByCountry .......  country: $country');
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('\n😡 😡  ListAPI.getSuppliersByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Supplier.fromJson(doc.data));
    });

    print('ListAPI.getSuppliersByCountry ############ found: ${list.length}');
    return list;
  }

  static Future<List<Company>> getCompaniesByCountry(String country) async {
    print('ListAPI.getCompaniesByCountry .......  country: $country');
    List<Company> list = List();
    var qs = await _firestore
        .collection('companies')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getCompaniesByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Company.fromJson(doc.data));
    });

    print('ListAPI.getCompaniesByCountry ############ found: ${list.length}');
    return list;
  }

  static Future<List<DeliveryAcceptance>> getDeliveryAcceptances(
      {String participantId, String participantType}) async {
    print(
        'ListAPI.getDeliveryAcceptances .......  participantId: $participantId');
    List<DeliveryAcceptance> list = List();
    var qs = await _firestore
        .collection('deliveryAcceptances')
        .where(participantType, isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptances $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryAcceptance.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
  }

  static Future<DeliveryAcceptance> getDeliveryAcceptanceForNote(
      String deliveryNoteId) async {
    print(
        'ListAPI.getDeliveryAcceptanceForNote ....... deliveryNoteId: $deliveryNoteId');
    DeliveryAcceptance da;

    var qs = await _firestore
        .collection('deliveryAcceptances')
        .where('deliveryNote', isEqualTo: deliveryNoteId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptanceForNote $e');
      return da;
    });

    if (qs.documents.isNotEmpty) {
      da = DeliveryAcceptance.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryAcceptanceForNote ############ found: ${qs.documents.length}');
    return da;
  }

  static Future<List<Supplier>> getSuppliers() async {
    print('\n🔵💦  💦  💦   ListAPI.getSuppliers .......  ');
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('😡 😡  ListAPI.getSuppliers $e');
      return list;
    });

    qs.documents.forEach((doc) {
      var m = Supplier.fromJson(doc.data);
      list.add(m);
    });

    print(
        '\n💦  💦  💦  ListAPI.getSuppliers ############ found: ${list.length}');
    return list;
  }

  static Future<List<InvestorProfile>> getInvestorProfiles() async {
    List<InvestorProfile> list = List();
    var qs = await _firestore
        .collection('investorProfiles')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorProfiles $e');
      return list;
    });

    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        list.add(new InvestorProfile.fromJson(doc.data));
      });
    }

    return list;
  }

  static Future<InvestorProfile> getInvestorProfile(String investorId) async {
    InvestorProfile profile;
    var qs = await _firestore
        .collection('investorProfiles')
        .where('investor', isEqualTo: investorId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorProfiles $e');
      return null;
    });

    if (qs.documents.isNotEmpty) {
      profile = InvestorProfile.fromJson(qs.documents.first.data);
      prettyPrint(profile.toJson(), 'getInvestorProfile');
    }

    return profile;
  }

  static Future<AutoTradeOrder> getAutoTradeOrder(String participantId) async {
    AutoTradeOrder order;
    var qs = await _firestore
        .collection('autoTradeOrders')
        .where('participantId', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeOrder $e');
      return null;
    });

    if (qs.documents.isNotEmpty) {
      order = AutoTradeOrder.fromJson(qs.documents.first.data);
      prettyPrint(order.toJson(), 'ListAPI.getAutoTradeOrder ');
    }

    return order;
  }

  static Future<List<AutoTradeOrder>> getAutoTradeOrders() async {
    List<AutoTradeOrder> list = List();
    var qs = await _firestore
        .collection('autoTradeOrders')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeOrders $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new AutoTradeOrder.fromJson(doc.data));
    });

    print('ListAPI.getAutoTradeOrders ############ found: ${list.length}');
    return list;
  }

  static Future<List<Sector>> getPrivateSectorTypes() async {
    List<Sector> list = List();
    var qs = await _firestore
        .collection('sectors')
        .orderBy('sectorName')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getPrivateSectorTypes $e');
      return list;
    });

    print('ListAPI.getPrivateSectorTypes found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new Sector.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvestorProfile>> getProfile(String participantId) async {
    List<InvestorProfile> list = List();
    var qs = await _firestore
        .collection('investorProfiles')
        .where('investor', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getProfile $e');
      return list;
    });

    print('ListAPI.getProfile found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new InvestorProfile.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<Sector>> getSectors() async {
    List<Sector> list = List();
    var qs = await _firestore
        .collection('sectors')
        .orderBy('sectorName')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSectors $e');
      return list;
    });

    print('\n🔵 🔵 🔵 ListAPI.getSectors found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new Sector.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<Investor>> getInvestors() async {
    List<Investor> list = List();
    var qs = await _firestore
        .collection('investors')
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestors $e');
      return list;
    });

    print('\n🔵 🔵 🔵  ListAPI.getInvestors found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new Investor.fromJson(doc.data));
    });

    return list;
  }
}

class OfferBag {
  Offer offer;
  List<InvoiceBid> invoiceBids = List();

  OfferBag({this.offer, this.invoiceBids});
  doPrint() {
//    prettyPrint(offer.toJson(), '######## OFFER:');
//    invoiceBids.forEach((m) {
//      prettyPrint(m.toJson(), '%%%%%%%%% BID:');
//    });
  }
}

class DashboardParms {
  String id;
  String documentId;
  int limit;

  DashboardParms({this.id, this.documentId, this.limit});
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'documentId': documentId,
        'limit': limit,
      };
}

class OpenOfferSummary {
  List<Offer> offers = List();
  int totalOpenOffers = 0;
  double totalOfferAmount = 0.00;
  int startedAfter;

  OpenOfferSummary(
      {this.offers,
      this.totalOpenOffers,
      this.totalOfferAmount,
      this.startedAfter});

  OpenOfferSummary.fromJson(Map data) {
    if (data['totalOpenOffers'] != null) {
      this.totalOpenOffers = data['totalOpenOffers'];
    } else {
      this.totalOpenOffers = 0;
    }
    if (data['totalOfferAmount'] != null) {
      this.totalOfferAmount = data['totalOfferAmount'] * 1.0;
    } else {
      this.totalOfferAmount = 0.00;
    }
    this.startedAfter = data['startedAfter'];
    if (data['offers'] != null) {
      List mOffers = data['offers'];
      offers = List();
      mOffers.forEach((o) {
        offers.add(Offer.fromJson(o));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalOpenOffers': totalOpenOffers,
        'startedAfter': startedAfter,
        'totalOfferAmount': totalOfferAmount,
        'offers': offers,
      };
}

class PurchaseOrderSummary {
  List<PurchaseOrder> purchaseOrders = List();
  int totalPurchaseOrders = 0;
  double totalAmount = 0.00;
  int startedAfter;

  PurchaseOrderSummary(this.purchaseOrders, this.totalPurchaseOrders,
      this.totalAmount, this.startedAfter);

  PurchaseOrderSummary.fromJson(Map data) {
    this.totalPurchaseOrders = data['totalPurchaseOrders'];
    this.totalAmount = data['totalAmount'] * 1.0;
    this.startedAfter = data['startedAfter'];
    if (data['purchaseOrders'] != null) {
      List mPOs = data['purchaseOrders'];
      purchaseOrders = List();
      mPOs.forEach((o) {
        purchaseOrders.add(PurchaseOrder.fromJson(o));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalPurchaseOrders': totalPurchaseOrders,
        'startedAfter': startedAfter,
        'totalAmount': totalAmount,
        'purchaseOrders': purchaseOrders,
      };
}

class InvoiceSummary {
  List<Invoice> invoices = List();
  int totalInvoices = 0;
  double totalAmount = 0.00;
  int startedAfter;

  InvoiceSummary(
      this.invoices, this.totalInvoices, this.totalAmount, this.startedAfter);

  InvoiceSummary.fromJson(Map data) {
    this.totalInvoices = data['totalInvoices'];
    this.totalAmount = data['totalAmount'] * 1.0;
    this.startedAfter = data['startedAfter'];
    if (data['invoices'] != null) {
      List mPOs = data['invoices'];
      invoices = List();
      mPOs.forEach((o) {
        invoices.add(Invoice.fromJson(o));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalInvoices': totalInvoices,
        'startedAfter': startedAfter,
        'totalAmount': totalAmount,
        'invoices': invoices,
      };
}
