import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class InvoiceBidCard extends StatelessWidget {
  final InvoiceBid bid;
  final bool showItemNumber;
  final double elevation;

  InvoiceBidCard({this.bid, this.elevation, this.showItemNumber});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 4.0 : elevation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: <Widget>[
                  showItemNumber == true
                      ? Container(
                          width: 20.0,
                          child: Text(
                            '${bid.itemNumber}',
                            style: Styles.blackBoldSmall,
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid == null
                            ? '0.00'
                            : getFormattedDateLongWithTime(
                                '${bid.date}', context),
                        style: Styles.blackSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Supplier', style: Styles.greyLabelSmall)),
                  Flexible(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          bid == null
                              ? 'Supplier name Unavailable'
                              : '${bid.supplierName}',
                          style: Styles.blackBoldSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Customer', style: Styles.greyLabelSmall)),
                  Flexible(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          bid.customerName == null
                              ? 'Customer name Unavailable'
                              : '${bid.customerName}',
                          style: Styles.blackBoldSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Bid Time', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.date == null
                            ? '0.00'
                            : getFormattedDateHour('${bid.date}'),
                        style: Styles.blackSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Reserved', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.reservePercent == null
                            ? '0.0%'
                            : '${bid.reservePercent.toStringAsFixed(1)} %',
                        style: Styles.purpleBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Discount', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid == null
                            ? '0.0%'
                            : '${bid.discountPercent.toStringAsFixed(1)} %',
                        style: Styles.blackBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: <Widget>[
                  Text('Expires', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid == null
                            ? ''
                            : '${getFormattedDateLong(bid.endTime, context)}',
                        style: Styles.blackSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
              child: Row(
                children: <Widget>[
                  Text('Type', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.autoTradeOrder == null
                            ? 'Manual Trade'
                            : 'Automatic Trade',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
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
                      style: Styles.tealBoldLarge),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceBidsCard extends StatelessWidget {
  final List<InvoiceBid> bids;
  final double elevation;

  InvoiceBidsCard({this.bids, this.elevation});

  @override
  Widget build(BuildContext context) {
    var totalBids = bids.length;
    var totalValue = 0.0;
    var supMap = Map();
    var custMap = Map();
    var avgReserved = 0.0;
    var avgDiscount = 0.0;
    var tiles = List<ListTile>();
    var totReserved = 0.0;
    var totDiscountPerc = 0.0;
    var manualTrades = 0, autoTrades = 0;
    bids.forEach((b) {
      totalValue += b.amount;
      totReserved += b.reservePercent;
      totDiscountPerc += b.discountPercent;

      if (!supMap.containsKey(b.supplier)) {
        supMap[b.supplier] = b.supplierName;
      }
      if (!custMap.containsKey(b.customer)) {
        custMap[b.customerName] = b.customerName;
      }
      if (b.autoTradeOrder == null) {
        manualTrades++;
      } else {
        autoTrades++;
      }
    });
    avgReserved = totReserved / totalBids;
    avgDiscount = totDiscountPerc / totalBids;

    supMap.values.forEach((val) {
      var header = ListTile(
        title: Text(
          'Suppliers in Invoice Bids',
          style: Styles.blackBoldMedium,
        ),
      );
      tiles.add(header);
      var tile = ListTile(
        title: Text(
          val,
          style: Styles.blackMedium,
        ),
        leading: Icon(
          Icons.apps,
          color: getRandomColor(),
        ),
      );
      tiles.add(tile);
    });
    custMap.values.forEach((val) {
      var header = ListTile(
        title: Text(
          'Customers in Invoice Bids',
          style: Styles.blackBoldMedium,
        ),
      );
      tiles.add(header);
      var tile = ListTile(
        title: Text(
          val,
          style: Styles.blackMedium,
        ),
        leading: Icon(
          Icons.apps,
          color: getRandomColor(),
        ),
      );
      tiles.add(tile);
    });
    return Card(
      elevation: elevation == null ? 4.0 : elevation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Total Bids', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('$totalBids', style: Styles.blackBoldLarge),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child:
                          Text('Total Amount', style: Styles.greyLabelSmall)),
                  Flexible(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${getFormattedAmount('$totalValue', context)}',
                          style: Styles.blackBoldLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child:
                          Text('Avg Reserved', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('${avgReserved.toStringAsFixed(2)} %',
                        style: Styles.purpleBoldLarge),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child:
                          Text('Avg Discount', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('${avgDiscount.toStringAsFixed(1)} %',
                        style: Styles.blackBoldLarge),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child: Text('Auto Trades', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('$autoTrades', style: Styles.pinkBoldMedium),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 110.0,
                      child:
                          Text('Manual Trades', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('$manualTrades', style: Styles.blackBoldMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
