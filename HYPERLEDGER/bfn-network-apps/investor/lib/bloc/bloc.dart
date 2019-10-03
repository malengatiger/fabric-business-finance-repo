import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:flutter/material.dart';

final Bloc investorBloc = Bloc();

class Bloc {
  final StreamController<List<Offer>> _openOffersController =
      StreamController.broadcast();

  final StreamController<List<InvoiceBid>> _settledBidsController =
      StreamController.broadcast();
  final StreamController<List<InvoiceBid>> _unsettledBidsController =
      StreamController.broadcast();

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  final StreamController<ChatResponse> _chatController =
      StreamController<ChatResponse>.broadcast();

  final StreamController<DashboardData> _dashController =
      StreamController<DashboardData>.broadcast();
  final StreamController<String> _fcmMessageController =
      StreamController.broadcast();

  get dashboardStream => _dashController.stream;
  get openOffersStream => _openOffersController.stream;
  get settledBidsStream => _settledBidsController.stream;
  get unsettledBidsStream => _unsettledBidsController.stream;
  get chatResponseStream => _chatController.stream;
  get errorStream => _errorController.stream;
  get fcmStream => _fcmMessageController.stream;

  Investor _investor;
  Investor get investor => _investor;
  DashboardData _dashboardData;
  DashboardData get dashboardData => _dashboardData;

  Bloc() {
    print(
        '\n\n🌼 🌼 🌼 🌼 🌼 🌼 🌼 🌼 🌼 🌼 🌼 🌼  Investor Bloc - CONSTRUCTOR - 🌼 🌼 🌼');
    initialize();
  }

  initialize() async {
    print('\n🌼 🌼 🌼 🌼 🌼 🌼 🌼 🌼 Bloc - initialize - 🌼');
    _investor = await SharedPrefs.getInvestor();
    await getCachedDashboard();
    await refreshRemoteDashboard();
  }

  receiveOfferMessage(Offer offer, BuildContext ctx) {
    var msg =
        '🔆 Offer arrived:  ${getFormattedAmount('${offer.offerAmount}', ctx)} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  receiveInvoiceBidMessage(InvoiceBid invoiceBid, BuildContext ctx) {
    var msg =
        '🔆 Invoice Bid arrived:  ${getFormattedAmount('${invoiceBid.amount}', ctx)} ${getFormattedDateHour('${DateTime.now().toString()}')}';
    _fcmMessageController.sink.add(msg);
  }

  Future getCachedDashboard() async {
    print(
        '\n💦  💦  💦  getCachedDashboard ----- 💦  REFRESH from local cache ...............');
    try {
      _dashboardData = await Database.getDashboard();
      if (_dashboardData != null) _dashController.sink.add(_dashboardData);
    } catch (e) {
      _errorController.sink.add(e.toString());
    }
  }

  Future refreshRemoteDashboard() async {
    if (_investor == null) return null;
    print(
        '\n💦  💦  💦  refreshRemoteDashboard ----- 💦  REFRESH from web api ...............');
    try {
      _dashboardData =
          await ListAPI.getInvestorDashboardData(_investor.participantId);
      _dashboardData.averageBidAmount =
          _dashboardData.totalBidAmount / _dashboardData.totalBids;

      var totDiscount = 0.0;
      var totAmt = 0.0;
      _dashboardData.unsettledBids.forEach((bid) {
        totDiscount += bid.discountPercent;
        totAmt += bid.amount;
      });
      _dashboardData.settledBids.forEach((bid) {
        totDiscount += bid.discountPercent;
        totAmt += bid.amount;
      });

      _dashboardData.averageDiscountPerc = totDiscount /
          (_dashboardData.settledBids.length +
              _dashboardData.unsettledBids.length);
      _dashboardData.averageBidAmount = totAmt /
          (_dashboardData.settledBids.length +
              _dashboardData.unsettledBids.length);
      _dashboardData.totalBidAmount = totAmt;
      print('💊 💊 💊  feeding dash stream .... $_dashboardData 💊 💊 💊');
      _dashController.sink.add(_dashboardData);
      await Database.saveDashboard(_dashboardData);
    } catch (e) {
      _errorController.sink.add(e.toString());
    }
  }

  close() {
    _fcmMessageController.close();
    _openOffersController.close();
    _chatController.close();
    _errorController.close();
    _settledBidsController.close();
    _unsettledBidsController.close();
    _dashController.close();
  }
}
