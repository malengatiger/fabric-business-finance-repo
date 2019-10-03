import 'dart:async';

import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreListAPI {
  static final Firestore _firestore = Firestore.instance;

  static Future<List<Supplier>> getSuppliersBySector(String sector) async {
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .where('privateSectorType', isEqualTo: sector)
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSuppliersBySector ERROR $e');
      return list;
    });
    qs.documents.forEach((doc) {
      Supplier s = new Supplier.fromJson(doc.data);
      list.add(s);
    });
    print('FirestoreListAPI.getSuppliersBySector .. found: ${list.length}');
    return list;
  }

  static Future<List<Supplier>> getSuppliers() async {
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSuppliers ERROR $e');
      return list;
    });
    qs.documents.forEach((doc) {
      var s = new Supplier.fromJson(doc.data);
      list.add(s);
    });
    print('FirestoreListAPI.getSuppliers .. found: ${list.length}');
    return list;
  }

  static Future<List<PurchaseOrder>> getSupplierPurchaseOrders(
      Supplier supplier) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.participantId)
        .collection('purchaseOrders')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierPurchaseOrders  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getSupplierPurchaseOrders found ${list.length}');
    return list;
  }

  static Future<List<PurchaseOrder>> getGovtPurchaseOrders(
      Customer govtEntity) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('govtEntities')
        .document(govtEntity.participantId)
        .collection('purchaseOrders')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getGovtPurchaseOrders  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getGovtPurchaseOrders found ${list.length}');
    return list;
  }

  static Future<List<DeliveryNote>> getSupplierDeliveryNotes(
      Supplier supplier) async {
    List<DeliveryNote> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.participantId)
        .collection('deliveryNotes')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierDeliveryNotes  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new DeliveryNote.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getSupplierDeliveryNotes found ${list.length}');
    return list;
  }

  static Future<List<DeliveryNote>> getGovtDeliveryNotes(
      Customer govtEntity) async {
    List<DeliveryNote> list = List();
    var querySnapshot = await _firestore
        .collection('govtEntities')
        .document(govtEntity.participantId)
        .collection('deliveryNotes')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getGovtDeliveryNotes  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new DeliveryNote.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getGovtDeliveryNotes found ${list.length}');
    return list;
  }

  static Future<List<Invoice>> getSupplierInvoices(Supplier supplier) async {
    List<Invoice> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.participantId)
        .collection('invoices')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierInvoices  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var invoice = new Invoice.fromJson(doc.data);
      list.add(invoice);
    });
    print('FirestoreListAPI.getSupplierInvoices found ${list.length}');
    return list;
  }

  static Future<List<Invoice>> getGovtInvoices(Supplier govtEntity) async {
    List<Invoice> list = List();
    var querySnapshot = await _firestore
        .collection('invoices')
        .document(govtEntity.participantId)
        .collection('invoices')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getGovtInvoices  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var invoice = new Invoice.fromJson(doc.data);
      list.add(invoice);
    });
    print('FirestoreListAPI.getGovtInvoices found ${list.length}');
    return list;
  }

  static Future<List<GovtInvoiceSettlement>> getSupplierGovtSettlements(
      Customer supplier) async {
    List<GovtInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.participantId)
        .collection('govtInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierGovtSettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new GovtInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getSupplierGovtSettlements found ${list.length}');
    return list;
  }

  static Future<List<GovtInvoiceSettlement>> getGovtSettlements(
      Customer govtEntity) async {
    List<GovtInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('govtEntities')
        .document(govtEntity.participantId)
        .collection('govtInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getGovtSettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new GovtInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getGovtSettlements found ${list.length}');
    return list;
  }

  static Future<List<CompanyInvoiceSettlement>> getSupplierCompanySettlements(
      Supplier supplier) async {
    List<CompanyInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.participantId)
        .collection('companyInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierCompanySettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new CompanyInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print(
        'FirestoreListAPI.getSupplierCompanySettlements found ${list.length}');
    return list;
  }

  static Future<List<InvestorInvoiceSettlement>> getSupplierInvestorSettlements(
      Supplier supplier) async {
    List<InvestorInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.participantId)
        .collection('investorInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierInvestorSettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new InvestorInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print(
        'FirestoreListAPI.getSupplierInvestorSettlements found ${list.length}');
    return list;
  }
}
