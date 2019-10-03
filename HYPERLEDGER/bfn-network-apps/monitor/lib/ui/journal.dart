import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  final List<InvoiceBid> bids;

  JournalPage({this.bids});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double totalBidAmount = 0.00;
  double totalInvalidAmount = 0.00;
  int totalBids = 0;
  int totalInvalids = 0;
  List<InvoiceBid> bids;
  @override
  initState() {
    super.initState();
    // _getData();
  }

  Widget _getBidView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total'),
              ),
              Text(
                totalBidAmount == null
                    ? '0.00'
                    : getFormattedAmount('$totalBidAmount', context),
                style: Styles.purpleBoldReallyLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 4.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total Bids'),
              ),
              Text(
                '${bids.length}',
                style: Styles.blackBoldMedium,
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: bids == null ? 0 : bids.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _showBidDetail(bids.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                    child: InvoiceBidCard(
                      bid: bids.elementAt(index),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getInvalidView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 0.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('Total'),
                ),
                Text(
                  totalInvalidAmount == null
                      ? '0.00'
                      : getFormattedAmount('$totalInvalidAmount', context),
                  style: Styles.pinkBoldReallyLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 4.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('Total Bids'),
                ),
                Text(
                  '${bids.length}',
                  style: Styles.blueBoldMedium,
                ),
              ],
            ),
          ),
          new Flexible(
            child: new ListView.builder(
                itemCount: bids == null ? 0 : bids.length,
                itemBuilder: (BuildContext context, int index) {
                  return new GestureDetector(
                    onTap: () {
                      _showBidDetail(bids.elementAt(index));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 4.0, right: 4.0),
                      child: InvoiceBidCard(
                        bid: bids.elementAt(index),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _calcInvalids() {
//    var map = HashMap<String, Offer>();
//    bids.forEach((m) {
//      map['${m.offer}'] = m.offer;
//    });
//    totalInvalidAmount = 0.00;
//    totalBidAmount = 0.00;
//
//    map.forEach((key, off) {
//      totalInvalidAmount += off.offerAmount;
//    });
//    bids.forEach((m) {
//      totalBidAmount += m.amount;
//    });
  }

  @override
  Widget build(BuildContext context) {
    bids = widget.bids;
    _calcInvalids();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Trade Session Monitor',
            style: Styles.whiteBoldMedium,
          ),
          elevation: 16.0,
          bottom: TabBar(tabs: [
            Tab(
              text: 'Bids Executed',
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
            ),
            Tab(
              text: 'Invalid Trades',
              icon: Icon(
                Icons.clear,
                color: Colors.red.shade900,
              ),
            ),
          ]),
        ),
        body: TabBarView(children: [
          _getBidView(),
          _getInvalidView(),
        ]),
      ),
    );
  }

  void _showBidDetail(InvoiceBid elementAt) {}
}

class InvoiceBidCard extends StatelessWidget {
  final InvoiceBid bid;

  InvoiceBidCard({this.bid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Bid Date', style: Styles.greyLabelSmall),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      bid.date == null
                          ? '0.00'
                          : getFormattedDateLong('${bid.date}', context),
                      style: Styles.blackBoldSmall),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Text('Bid Time', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.date == null
                            ? '0.00'
                            : getFormattedDateHour('${bid.date}'),
                        style: Styles.purpleBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  Text('Investor', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(bid.investorName,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text('Amount', style: Styles.greyLabelSmall),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      bid.amount == null
                          ? '0.00'
                          : getFormattedAmount('${bid.amount}', context),
                      style: Styles.tealBoldMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
