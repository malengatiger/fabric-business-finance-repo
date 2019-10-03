import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';

abstract class InvestorModelBlocListener {
  onEvent(String message);
}

class InvestorModelBloc implements AppModelListener {
  final StreamController<InvestorAppModel> _appModelController =
      StreamController<InvestorAppModel>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<ChatResponse> _chatController =
      StreamController<ChatResponse>.broadcast();
  final InvestorAppModel _appModel = InvestorAppModel();

  InvestorModelBloc() {
    print(
        '\n\n🌼 🌼 InvestorModelBloc - CONSTRUCTOR - 🌼 set listener and initialize app model');
    _appModel.setModelListener(this);
    _appModel.initialize();
  }

  get appModel => _appModel;

  refreshDashboard() async {
    await _appModel.refreshRemoteDashboard();
    _appModelController.sink.add(_appModel);
  }

  refreshDashboardWithListener(InvestorModelBlocListener listener) async {
    await _appModel.refreshRemoteDashboardWithListener(listener);
    _appModelController.sink.add(_appModel);
  }

  closeStream() {
    _appModelController.close();
    _errorController.close();
    _chatController.close();
  }

  get appModelStream => _appModelController.stream;
  get chatResponseStream => _chatController.stream;

  receiveChatResponse(ChatResponse chatResponse) {
    _chatController.sink.add(chatResponse);
  }

  @override
  onComplete() {
    print(
        '\n\nInvestorModelBloc.onComplete ########## adding model to stream sink ......... ');
    _appModelController.sink.add(_appModel);
  }

  @override
  onError(String message) {
    _errorController.sink.add(message);
    return null;
  }
}

final investorModelBloc = InvestorModelBloc();

abstract class AppModelListener {
  onComplete();
  onError(String message);
}

class InvestorAppModel {
  String _title = 'BFN State Test';
  int _pageLimit = 10;
  DashboardData _dashboardData = DashboardData();
  List<InvoiceBid> _unsettledInvoiceBids, _settledInvoiceBids;
  List<InvestorInvoiceSettlement> _settlements;
  List<Offer> _offers;
  Investor _investor;
  AppModelListener _modelListener;

  int get pageLimit => _pageLimit;
  List<InvoiceBid> get unsettledInvoiceBids => _unsettledInvoiceBids;
  List<InvoiceBid> get settledInvoiceBids => _settledInvoiceBids;
  List<Offer> get offers => _offers;
  List<InvestorInvoiceSettlement> get settlements => _settlements;
  Investor get investor => _investor;
  DashboardData get dashboardData => _dashboardData;
  String get title => _title;

  double getTotalSettledBidAmount() {
    if (_settledInvoiceBids == null) return 0.0;
    var t = 0.0;
    _settledInvoiceBids.forEach((b) {
      t += b.amount;
    });
    return t;
  }

  double getTotalUnsettledBidAmount() {
    var t = 0.0;
    _unsettledInvoiceBids.forEach((b) {
      t += b.amount;
    });
    return t;
  }

  void setModelListener(AppModelListener listener) {
    _modelListener = listener;
    print('InvestorAppModel.setModelListener listener has been set.');
  }

  Future processSettledBid(InvoiceBid bid) async {
    try {
      bid.isSettled = true;
      _settledInvoiceBids.insert(0, bid);

      _unsettledInvoiceBids.remove(bid);
      _setItemNumbers(_unsettledInvoiceBids);
      print(
          'InvestorAppModel._removeBidFromCache bids in cache: ${_unsettledInvoiceBids.length} added to settled: ${_settledInvoiceBids.length}');
      _dashboardData.unsettledBids = _unsettledInvoiceBids;
      _dashboardData.settledBids = _settledInvoiceBids;
      await Database.saveDashboard(_dashboardData);
      if (_modelListener != null) {
        _modelListener.onComplete();
      }
    } catch (e) {
      print(e);
      _modelListener.onError(e.toString());
    }
    return null;
  }

  void invoiceBidArrived(InvoiceBid invoiceBid) async {
    try {
      _dashboardData.totalOpenOffers--;
      _dashboardData.totalOfferAmount -= invoiceBid.amount;
      _dashboardData.totalOpenOfferAmount -= invoiceBid.amount;

      if (invoiceBid.investor == investor.participantId) {
        _dashboardData.totalUnsettledBids++;
        _dashboardData.totalUnsettledAmount += invoiceBid.amount;
        _dashboardData.unsettledBids.insert(0, invoiceBid);
        _unsettledInvoiceBids.insert(0, invoiceBid);
        _dashboardData.totalBids++;
        _dashboardData.totalBidAmount += invoiceBid.amount;
        await Database.saveDashboard(_dashboardData);
      }
      if (_modelListener != null) {
        _modelListener.onComplete();
      }
    } catch (e) {
      print(e);
      _modelListener.onError(e.toString());
    }
  }

  Future updatePageLimit(int pageLimit) async {
    await SharedPrefs.savePageLimit(pageLimit);
    _pageLimit = pageLimit;
  }

  void initialize() async {
    print(
        '\n\n🔥 🔥 🔥 InvestorAppModel2.initialize ################################ ');
    _investor = await SharedPrefs.getInvestor();
    if (_investor == null) return;
    _pageLimit = await SharedPrefs.getPageLimit();
    if (_pageLimit == null) {
      _pageLimit = 10;
    }
    await refreshDashboard();
    print(
        '\n\n🔥 🔥 🔥 InvestorAppModel2.initialize - REFRESH MODEL COMPLETE - refreshDashboard *************');
  }

  Future refreshDashboard() async {
    print(
        '🐸 🐸 InvestorAppModel2.refreshDashboard ............................');
    try {
      _dashboardData = await Database.getDashboard();
      if (_dashboardData != null) {
        print(
            '\n\n🐸 🐸 🐸 🐸 InvestorAppModel2.refreshDashboard - _dashboardData != null calling  _modelListener.onComplete();\n');
        setLists();
        _modelListener.onComplete();
      } else {
        print(
            '🐸 InvestorAppModel2.refreshDashboard ...... dashboard is null.');
      }
      await refreshRemoteDashboard();
      doPrint();

      if (_modelListener != null) {
        print(
            '\n\nInvestorAppModel2.refreshDashboard:  after refresh from functions: calling  _modelListener.onComplete();\n');
        _modelListener.onComplete();
      }
    } catch (e) {
      print(e);
      _modelListener.onError(e.toString());
    }
  }

  Future refreshRemoteDashboard() async {
    if (_investor == null) return null;
    print(
        '💦  💦  💦  InvestorAppModel2.refreshDashboard ----- 💦  REFRESH from web api ...............');
    try {
      _dashboardData =
          await ListAPI.getInvestorDashboardData(_investor.participantId);
      await Database.saveDashboard(_dashboardData);
      setLists();
    } catch (e) {
      _modelListener.onError(e.toString());
    }
  }

  Future refreshRemoteDashboardWithListener(
      InvestorModelBlocListener listener) async {
    if (_investor == null) {
      _investor = await SharedPrefs.getInvestor();
    }
    print(
        'InvestorAppModel2.refreshDashboard ----- REFRESH from functions ...............');
    try {
      _dashboardData =
          await ListAPI.getInvestorDashboardData(_investor.participantId);
      await Database.saveDashboard(_dashboardData);
      setLists(mListener: listener);
    } catch (e) {
      _modelListener.onError(e.toString());
    }
  }

  void setLists({InvestorModelBlocListener mListener}) {
    _settledInvoiceBids = _dashboardData.settledBids;
    _setItemNumbers(_settledInvoiceBids);
    if (mListener != null) {
      mListener.onEvent(
          'Settled Invoice Bids loaded: ${_settledInvoiceBids.length}');
    }
    _unsettledInvoiceBids = _dashboardData.unsettledBids;
    _setItemNumbers(_unsettledInvoiceBids);
    if (mListener != null) {
      mListener.onEvent(
          'Unsettled Invoice Bids loaded: ${_unsettledInvoiceBids.length}');
    }
    _offers = _dashboardData.openOffers;
    _setItemNumbers(_offers);
    if (mListener != null) {
      mListener.onEvent('Offers loaded: ${_offers.length}');
    }
    _settlements = _dashboardData.settlements;
    _setItemNumbers(_settlements);
    if (mListener != null) {
      mListener.onEvent('Settlements loaded: ${_settlements.length}');
    }
  }

  void _setItemNumbers(List<Findable> list) {
    if (list == null) return;
    int num = 1;
    list.forEach((o) {
      o.itemNumber = num;
      num++;
    });
  }

  void doPrint() {
    print(
        'InvestorAppModel2.doPrint ################################### START PRINT **');
    if (_unsettledInvoiceBids != null)
      print(
          'InvestorAppModel.doPrint _unsettledInvoiceBids in Model: ${_unsettledInvoiceBids.length}');
    if (_offers != null)
      print('InvestorAppModel.doPrint offers in Model: ${_offers.length}');
    if (_settlements != null)
      print(
          'InvestorAppModel.doPrint _settlements in Model: ${_settlements.length}');
    if (_settledInvoiceBids != null)
      print(
          'InvestorAppModel.doPrint _settledInvoiceBids in Model: ${_settledInvoiceBids.length}');
    if (_investor != null) {
      print('doPrint: ######## Investor in Model: ${_investor.name}');
    }
    if (_dashboardData != null) {
      print(
          'doPrint: ####### DashboardData inside Model: settled: ${_settledInvoiceBids.length} unsettled: ${_unsettledInvoiceBids.length} offers: ${_offers.length} settlements: ${_settlements.length}');
    }
    print(
        'InvestorAppModel2.doPrint ################################### END PRINT **');
  }
}
