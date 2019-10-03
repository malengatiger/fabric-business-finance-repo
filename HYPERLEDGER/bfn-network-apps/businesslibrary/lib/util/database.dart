import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:path_provider/path_provider.dart';

class Database {
  static File jsonFile;
  static Directory dir;
  static bool fileExists;

  static Future<List<Sector>> getSector() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/sectors.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      Sectors w = new Sectors.fromJson(map);
      print('Database ## 🌼 🌺  returning sectors found: ${w.sectors.length}');
      return w.sectors;
    } else {
      return null;
    }
  }

  static Future<int> saveSectors(Sectors sectors) async {
    Map map = sectors.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/sectors.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print('Database_saveSectors  ## file exists ...writing sectors file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'Database_saveSectors ##  has cached list of sectors   🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${sectors.sectors.length}');
      return 0;
    } else {
      print(
          'FileUti_saveSectorsl ## file does not exist ...creating and writing sectors file');
      var file = await jsonFile.create();
      var x = await file.writeAsString(json.encode(map));
      print('Database_saveSectors ## looks like we cooking with gas!' + x.path);
      return 0;
    }
  }

  static Future<List<InvoiceBid>> getUnsettledInvoiceBids() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/unsettledinvoiceBids.json");
    fileExists = await jsonFile.exists();

    try {
      if (fileExists) {
        String string = await jsonFile.readAsString();
        Map map = json.decode(string);
        InvoiceBids w = new InvoiceBids.fromJson(map);
        print(
            'Database ## 🌼 🌺  getUnsettledInvoiceBids - returning InvoiceBids found: ${w.bids.length}');
        return w.bids;
      } else {
        return List();
      }
    } catch (e) {
      return List();
    }
  }

  static Future<int> saveUnsettledInvoiceBids(InvoiceBids bids) async {
    Map map = bids.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/unsettledinvoiceBids.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      jsonFile.writeAsString(json.encode(map));
      print(
          'Database_saveUnsettledInvoiceBids ##  has cached list of InvoiceBids    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${bids.bids.length}\n\n');
      return 0;
    } else {
      print(
          'FileUti_saveUnsettledInvoiceBids## file does not exist ...creating and writing InvoiceBids file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      return 0;
    }
  }

  static Future<DashboardData> getDashboard() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/dashboardData.json");
    fileExists = await jsonFile.exists();

    try {
      if (fileExists) {
        String string = await jsonFile.readAsString();
        Map map = json.decode(string);
        DashboardData w = new DashboardData.fromJson(map);
        print('Database ## 🌼 🌺  getDashboard - returning DashboardData');
        return w;
      } else {
        print('Database.getDashboard - ERROR - file does not exist');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<int> saveDashboard(DashboardData dashboardData) async {
    Map map = dashboardData.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/dashboardData.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      jsonFile.writeAsString(json.encode(map));
      print(
          'Database_saveDashboard ##  has cached dashboard   🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  dashboardData.json: ${jsonFile.length()}\n\n');
      return 0;
    } else {
      print(
          'Database_saveDashboard ## file does not exist ...creating and writing dashboardData file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      return 0;
    }
  }

  static Future<List<InvoiceBid>> getSettledInvoiceBids() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/settledinvoiceBids.json");
    fileExists = await jsonFile.exists();

    try {
      if (fileExists) {
        String string = await jsonFile.readAsString();
        Map map = json.decode(string);
        InvoiceBids w = new InvoiceBids.fromJson(map);
        print(
            '\nDatabase ## 🌼 🌺  getSettledInvoiceBids - returning SettledInvoiceBids found: ${w.bids.length} \n\n');
        return w.bids;
      } else {
        return List();
      }
    } catch (e) {
      return List();
    }
  }

  static Future<int> saveSettledInvoiceBids(InvoiceBids bids) async {
    Map map = bids.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/settledinvoiceBids.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      jsonFile.writeAsString(json.encode(map));
      print(
          'Database_saveSettledInvoiceBids ##  has cached list of SettledInvoiceBids    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${bids.bids.length}\n\n');
      return 0;
    } else {
      print(
          'FileUti_saveSettledInvoiceBids ## file does not exist ...creating and writing SettledInvoiceBids file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      return 0;
    }
  }

  static Future<List<PurchaseOrder>> getPurchaseOrders() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/PurchaseOrders.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      PurchaseOrders w = new PurchaseOrders.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning PurchaseOrders found: ${w.orders.length}');
      return w.orders;
    }
    return null;
  }

  static Future<int> savePurchaseOrders(PurchaseOrders purchaseOrders) async {
    Map map = purchaseOrders.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/PurchaseOrders.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print(
          '🍔 🍔 Database_savePurchaseOrders  ## file exists ...writing purchaseOrders file');
      jsonFile.writeAsString(json.encode(map));
      print(
          '🍔 🍔 🍔 Database_savePurchaseOrders ##  has cached list of purchaseOrders --    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${purchaseOrders.orders.length}');
      return 0;
    } else {
      print(
          '🍔 🍔 Database_savePurchaseOrders ## file does not exist ...creating and writing purchaseOrders file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          '🍔 🍔 🍔 Database.savePurchaseOrders  🌷 ${file.path} length: ${file.length()}');
      return 0;
    }
  }

  static Future<List<DeliveryNote>> getDeliveryNotes() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/notes.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      DeliveryNotes w = new DeliveryNotes.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning DeliveryNotes  ### found: ${w.notes.length}');
      //w.printFirstAndLast();
      return w.notes;
    } else {
      return List<DeliveryNote>();
    }
  }

  static Future<int> saveDeliveryAcceptances(
      DeliveryAcceptances deliveryAcceptances) async {
    Map map = deliveryAcceptances.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/DeliveryAcceptances.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print(
          '🍇  🍇  🍇 Database_saveDeliveryAcceptances  ## file exists ...writing deliveryAcceptances file');
      jsonFile.writeAsString(json.encode(map));
      print(
          '🍇  🍇  🍇 Database_saveDeliveryAcceptances ##  has cached list of deliveryAcceptances --    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${deliveryAcceptances.deliveryAcceptances.length}');
      return 0;
    } else {
      print(
          '🍇  🍇  🍇  Database_saveDeliveryAcceptances ## file does not exist ...creating and writing po file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          ' 🍇  🍇  🍇  Database.saveDeliveryAcceptances  🌷 ${file.path} length: ${file.length()}');
      return 0;
    }
  }

  static Future<List<DeliveryAcceptance>> getDeliveryAcceptances() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/DeliveryAcceptances.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      var w = new DeliveryAcceptances.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning DeliveryAcceptances  ### found: ${w.deliveryAcceptances.length}');
      return w.deliveryAcceptances;
    } else {
      return List<DeliveryAcceptance>();
    }
  }

  static Future<int> saveDeliveryNotes(DeliveryNotes notes) async {
    Map map = notes.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/notes.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print(
          '🥦 🥦 🥦 Database_saveDeliveryNotes  ## file exists ...writing DeliveryNotes file');
      jsonFile.writeAsString(json.encode(map));
      print(
          '🥦 🥦 🥦 Database_saveDeliveryNotes##  has cached list of delivery notes --    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${notes.notes.length}');
      return 0;
    } else {
      print(
          '🥦 🥦 🥦 Database_saveDeliveryNotes ## file does not exist ...creating and writing delivery note file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          '🥦 🥦 🥦 Database.saveDeliveryNotes  🌷 ${file.path} length: ${file.length()}');
      return 0;
    }
  }

  static Future<List<Invoice>> getInvoices() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/invoices.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      Invoices w = new Invoices.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning invoices  ### found: ${w.invoices.length}');
      return w.invoices;
    } else {
      return List();
    }
  }

  static Future<int> saveInvoices(Invoices invoices) async {
    Map map = invoices.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/invoices.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print(
          '🎁 🎁 🎁 Database_saveInvoices  ## file exists ...writing invoices file');
      jsonFile.writeAsString(json.encode(map));
      print(
          '🎁 🎁 🎁  Database_saveInvoices ##  has cached list of invoices --    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺   🌷 🌷 🌷: ${invoices.invoices.length}');
      return 0;
    } else {
      print(
          '🎁 🎁 🎁  Database_saveInvoices ## file does not exist ...creating and writing invoice file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          '🎁 🎁 🎁  Database.saveInvoices  🌷 ${file.path} length: ${file.length()}');
      return 0;
    }
  }

  static Future<List<Offer>> getOffers() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/offers.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      Offers w = new Offers.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning offers  ### found: ${w.offers.length}');
      //w.printFirstAndLast();
      return w.offers;
    } else {
      return null;
    }
  }

  static Future<int> saveOffers(Offers offers) async {
    Map map = offers.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/offers.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      jsonFile.writeAsString(json.encode(map));
      print(
          '🎁 🎁 🎁  Database_saveOffers ##  has cached list of offers --  ### ))))))))) : ${offers.offers.length}');
      return 0;
    } else {
      print(
          '🎁 🎁 🎁  Database_saveOffers ## file does not exist ...creating and writing offers file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          '🎁 🎁 🎁  Database.saveOffers ${file.path} length: ${file.length()}');
      return 0;
    }
  }

  static Future<List<InvoiceAcceptance>> getInvoiceAcceptances() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/InvoiceAcceptance.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      InvoiceAcceptances w = new InvoiceAcceptances.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning invoiceAcceptances  ### found: ${w.invoiceAcceptances.length}');
      return w.invoiceAcceptances;
    } else {
      return null;
    }
  }

  static Future<int> saveInvoiceAcceptances(
      InvoiceAcceptances acceptances) async {
    Map map = acceptances.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/InvoiceAcceptance.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print(
          'saveInvoiceAcceptances  ## file exists ...writing InvoiceAcceptances file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'Database_saveInvoiceAcceptances ##  has cached list of acceptances --    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${acceptances.invoiceAcceptances.length}');
      return 0;
    } else {
      print(
          'Database_saveInvoiceAcceptances ## file does not exist ...creating and writing InvoiceAcceptances file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          'Database.saveInvoiceAcceptances ${file.path} length: ${file.length()}');
      return 0;
    }
  }

  static Future<List<InvestorInvoiceSettlement>>
      getInvestorInvoiceSettlements() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/InvestorInvoiceSettlement.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      InvestorInvoiceSettlements w =
          new InvestorInvoiceSettlements.fromJson(map);
      print(
          'Database ## 🌼 🌺  returning InvestorInvoiceSettlements  ### found: ${w.settlements.length}');
      return w.settlements;
    } else {
      return null;
    }
  }

  static Future<int> saveInvestorInvoiceSettlements(
      InvestorInvoiceSettlements settlements) async {
    Map map = settlements.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/InvestorInvoiceSettlement.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      jsonFile.writeAsString(json.encode(map));
      print(
          '☘ Database_saveInvestorInvoiceSettlements##  has cached list of InvestorInvoiceSettlements --    🌼 🌺 🌼 🌺 🌼 🌺 🌼 🌺  : ${settlements.settlements.length}');
      return 0;
    } else {
      print(
          '☘ Database_saveInvestorInvoiceSettlements ## file does not exist ...creating and writing InvestorInvoiceSettlements file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      print(
          '☘ Database.saveInvestorInvoiceSettlements ${file.path} ☘ length: ${file.length()}');
      return 0;
    }
  }
}

class Sectors {
  List<Sector> sectors;

  Sectors(this.sectors);

  Sectors.fromJson(Map data) {
    List map = data['sectors'];
    this.sectors = List();
    map.forEach((m) {
      var sector = Sector.fromJson(m);
      sectors.add(sector);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'sectors': sectors,
      };
}

class PurchaseOrders {
  List<PurchaseOrder> orders = List();

  PurchaseOrders(this.orders);

  void printFirstAndLast() {
    if (orders.isNotEmpty) {
      prettyPrint(orders.first.toJson(), 'FIRST PURCHASE ORDER: ');
      prettyPrint(orders.last.toJson(), 'LAST PURCHASE ORDER: ');
    }
  }

  PurchaseOrders.fromJson(Map data) {
    List map = data['orders'];
    this.orders = List();
    if (map != null) {
      map.forEach((m) {
        var order = PurchaseOrder.fromJson(m);
        orders.add(order);
      });
    }
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'orders': orders,
      };
}

class InvoiceBids {
  List<InvoiceBid> bids;

  InvoiceBids(this.bids);

  InvoiceBids.fromJson(Map data) {
    List map = data['bids'];
    this.bids = List();
    map.forEach((m) {
      var bid = InvoiceBid.fromJson(m);
      bids.add(bid);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'bids': bids,
      };
}

class Offers {
  List<Offer> offers = List();

  Offers(this.offers);

  void printFirstAndLast() {
    if (offers.isNotEmpty) {
      prettyPrint(offers.first.toJson(), 'FIRST Offer: ');
      prettyPrint(offers.last.toJson(), 'LAST Offer: ');
    }
  }

  Offers.fromJson(Map data) {
    List map = data['offers'];
    this.offers = List();
    if (map != null) {
      map.forEach((m) {
        var offer = Offer.fromJson(m);
        offers.add(offer);
      });
    }
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'offers': offers,
      };
}

class Invoices {
  List<Invoice> invoices = List();

  Invoices(this.invoices);

  void printFirstAndLast() {
    print('\n\nInvoices.printFirstAndLast ......................');
    if (invoices.isNotEmpty) {
      prettyPrint(invoices.first.toJson(), 'FIRST Invoice: ');
      prettyPrint(invoices.last.toJson(), 'LAST Invoice: ');
    }
  }

  Invoices.fromJson(Map data) {
    List map = data['invoices'];
    this.invoices = List();
    map.forEach((m) {
      var invoice = Invoice.fromJson(m);
      invoices.add(invoice);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoices': invoices,
      };
}

class DeliveryNotes {
  List<DeliveryNote> notes = List();

  DeliveryNotes(this.notes);

  void printFirstAndLast() {
    print('\n\nDeliveryNotes.printFirstAndLast ......................');
    if (notes.isNotEmpty) {
      prettyPrint(notes.first.toJson(), 'FIRST DeliveryNote: ');
      prettyPrint(notes.last.toJson(), 'LAST DeliveryNote: ');
    }
  }

  DeliveryNotes.fromJson(Map data) {
    List map = data['notes'];
    this.notes = List();
    map.forEach((m) {
      var order = DeliveryNote.fromJson(m);
      notes.add(order);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'notes': notes,
      };
}

class DeliveryAcceptances {
  List<DeliveryAcceptance> deliveryAcceptances = List();

  DeliveryAcceptances(this.deliveryAcceptances);

  DeliveryAcceptances.fromJson(Map data) {
    List map = data['deliveryAcceptances'];
    this.deliveryAcceptances = List();
    map.forEach((m) {
      var acc = DeliveryAcceptance.fromJson(m);
      deliveryAcceptances.add(acc);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'deliveryAcceptances': deliveryAcceptances,
      };
}

class InvoiceAcceptances {
  List<InvoiceAcceptance> invoiceAcceptances = List();

  InvoiceAcceptances(this.invoiceAcceptances);
  InvoiceAcceptances.fromJson(Map data) {
    List map = data['invoiceAcceptances'];
    this.invoiceAcceptances = List();
    map.forEach((m) {
      var acc = InvoiceAcceptance.fromJson(m);
      invoiceAcceptances.add(acc);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceAcceptances': invoiceAcceptances,
      };
}

class InvestorInvoiceSettlements {
  List<InvestorInvoiceSettlement> settlements = List();

  InvestorInvoiceSettlements(this.settlements);
  InvestorInvoiceSettlements.fromJson(Map data) {
    List map = data['settlements'];
    this.settlements = List();
    map.forEach((m) {
      var acc = InvestorInvoiceSettlement.fromJson(m);
      settlements.add(acc);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'settlements': settlements,
      };
}
