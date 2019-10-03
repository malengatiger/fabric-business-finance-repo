
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';

class DashboardData {
  int totalOpenOffers = 0,
      totalUnsettledBids = 0,
      totalSettledBids = 0,
      totalBids = 0,
      totalOffers = 0,
      purchaseOrders = 0,
      invoices = 0,
      deliveryNotes = 0,
      cancelledOffers = 0,
      closedOffers = 0,
      totalSettlements = 0;
  double totalOpenOfferAmount = 0.00,
      totalUnsettledAmount = 0.00,
      totalSettledAmount = 0.00,
      totalBidAmount = 0.0,
      totalOfferAmount = 0.00,
      averageBidAmount = 0.00,
      totalPurchaseOrderAmount = 0.00,
      totalDeliveryNoteAmount = 0.00,
      totalInvoiceAmount = 0.00,
      averageDiscountPerc = 0.0,
      totalSettlementAmount = 0.00;
  String date;
  List<InvoiceBid> unsettledBids, settledBids;
  List<Offer> openOffers;
  List<InvestorInvoiceSettlement> settlements;

  DashboardData(
      {this.totalOpenOffers,
      this.totalUnsettledBids,
      this.totalSettledBids,
      this.totalBids,
      this.totalOffers,
      this.purchaseOrders,
      this.invoices,
      this.deliveryNotes,
      this.cancelledOffers,
      this.closedOffers,
      this.totalSettlements,
      this.totalSettlementAmount,
      this.totalOpenOfferAmount,
      this.totalUnsettledAmount,
      this.totalSettledAmount,
      this.totalBidAmount,
      this.totalOfferAmount,
      this.averageBidAmount,
      this.totalPurchaseOrderAmount,
      this.totalDeliveryNoteAmount,
      this.totalInvoiceAmount,
      this.averageDiscountPerc,
      this.date,
      this.unsettledBids,
      this.settledBids,
      this.openOffers,
      this.settlements});

  DashboardData.fromJson(Map data) {
    List<dynamic> settledBidMaps = data['settledBids'];
    List<dynamic> unsettledBidMaps = data['unsettledBids'];
    List<dynamic> settlementsMaps = data['settlements'];
    List<dynamic> offersMaps = data['openOffers'];

    try {
      settledBids = List();
      settledBidMaps.forEach((map) {
        var bid = InvoiceBid.fromJson(map);
        settledBids.add(bid);
      });
      unsettledBids = List();
      unsettledBidMaps.forEach((map) {
        var bid = InvoiceBid.fromJson(map);
        unsettledBids.add(bid);
      });
      settlements = List();
      settlementsMaps.forEach((map) {
        var iis = InvestorInvoiceSettlement.fromJson(map);
        settlements.add(iis);
      });
      openOffers = List();
      offersMaps.forEach((map) {
        var offer = Offer.fromJson(map);
        openOffers.add(offer);
      });

      this.totalOpenOffers = data['totalOpenOffers'];
      this.totalUnsettledBids = data['totalUnsettledBids'];
      this.totalSettledBids = data['totalSettledBids'];
      this.totalBids = data['totalBids'];
      this.totalOffers = data['totalOffers'];

      this.totalSettlements = data['totalSettlements'];

      if (data['totalSettlementAmount'] != null) {
        this.totalSettlementAmount = data['totalSettlementAmount'] * 1.0;
      }
      if (data['totalOpenOfferAmount'] != null) {
        this.totalOpenOfferAmount = data['totalOpenOfferAmount'] * 1.0;
      }
      if (data['totalDeliveryNoteAmount'] != null) {
        this.totalDeliveryNoteAmount = data['totalDeliveryNoteAmount'] * 1.0;
      }
      if (data['totalUnsettledAmount'] != null) {
        this.totalUnsettledAmount = data['totalUnsettledAmount'] * 1.0;
      }
      if (data['totalSettledAmount'] != null) {
        this.totalSettledAmount = data['totalSettledAmount'] * 1.0;
      }

      if (data['totalBidAmount'] != null) {
        this.totalBidAmount = data['totalBidAmount'] * 1.0;
      }
      if (data['totalOfferAmount'] != null) {
        this.totalOfferAmount = data['totalOfferAmount'] * 1.0;
      }
      if (data['averageBidAmount'] != null) {
        this.averageBidAmount = data['averageBidAmount'] * 1.0;
      }
      if (data['averageDiscountPerc'] != null) {
        this.averageDiscountPerc = data['averageDiscountPerc'] * 1.0;
      }
      if (data['totalPurchaseOrderAmount'] != null) {
        this.totalPurchaseOrderAmount = data['totalPurchaseOrderAmount'] * 1.0;
      }
      if (data['totalInvoiceAmount'] != null) {
        this.totalInvoiceAmount = data['totalInvoiceAmount'] * 1.0;
      }

      this.date = data['date'];

      this.deliveryNotes = data['deliveryNotes'];
      this.purchaseOrders = data['purchaseOrders'];
      this.invoices = data['invoices'];
      this.closedOffers = data['closedOffers'];
      this.cancelledOffers = data['cancelledOffers'];
    } catch (e) {
      print(e);
      print('DashboardData.fromJson - JSON parse failed');
    }
  }

  Map<String, dynamic> toJson() {
    List<dynamic> settledBidMaps = List();
    settledBids.forEach((b) {
      settledBidMaps.add(b.toJson());
    });
    List<dynamic> unsettledBidMaps = List();
    unsettledBids.forEach((b) {
      unsettledBidMaps.add(b.toJson());
    });
    List<dynamic> settlementsMaps = List();
    settlements.forEach((b) {
      settlementsMaps.add(b.toJson());
    });
    List<dynamic> offersMaps = List();
    openOffers.forEach((b) {
      offersMaps.add(b.toJson());
    });
    Map<String, dynamic> map = {
      'settledBids': settledBidMaps,
      'unsettledBids': unsettledBidMaps,
      'settlements': settlementsMaps,
      'openOffers': offersMaps,
      'totalOpenOffers': totalOpenOffers,
      'totalDeliveryNoteAmount': totalDeliveryNoteAmount,
      'totalUnsettledBids': totalUnsettledBids,
      'totalSettledBids': totalSettledBids,
      'totalBids': totalBids,
      'totalOffers': totalOffers,
      'totalPurchaseOrderAmount': totalPurchaseOrderAmount,
      'totalInvoiceAmount': totalInvoiceAmount,
      'totalOpenOfferAmount': totalOpenOfferAmount,
      'totalUnsettledAmount': totalUnsettledAmount,
      'totalSettledAmount': totalSettledAmount,
      'totalBidAmount': totalBidAmount,
      'totalOfferAmount': totalOfferAmount,
      'averageBidAmount': averageBidAmount,
      'averageDiscountPerc': averageDiscountPerc,
      'closedOffers': closedOffers,
      'date': date,
      'deliveryNotes': deliveryNotes,
      'purchaseOrders': purchaseOrders,
      'invoices': invoices,
      'cancelledOffers': cancelledOffers,
    };

    return map;
  }

}
