import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class InvestorSummaryCard extends StatelessWidget {
  final DashboardData data;
  final BuildContext context;
  final InvestorCardListener listener;
  final double elevation;

  InvestorSummaryCard({this.data, this.context, this.listener, this.elevation});

  Widget _getTotalBids() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 70.0,
          child: Text(
            '# Bids',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            data == null ? '0' : '${getTotalBids()}',
            style: Styles.blackBoldMedium,
          ),
        ),
      ],
    );
  }

  String getTotalBids() {
    var total = 0;
    if (data != null) {
      total = data.unsettledBids.length;
    }
    if (data != null) {
      total += data.settledBids.length;
    }
    return getFormattedNumber(total, context);
  }

  Widget _getTotalBidValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 70.0,
          child: Text(
            'Total Bids',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            data == null
                ? '0.00'
                : '${getFormattedAmount('${getTotalBidAmount()}', context)}',
            style: Styles.blackBoldLarge,
          ),
        ),
      ],
    );
  }

  String getTotalBidAmount() {
    if (data == null) {
      return '';
    }
    return getFormattedAmount('${data.totalBidAmount}', context);
  }

  Widget _getAverageDiscount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Avg Discount',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            data == null ? '0.0%' : '${getAverageDiscountPerc()}',
            style: Styles.purpleBoldSmall,
          ),
        ),
      ],
    );
  }

  String getAverageDiscountPerc() {
    if (data == null) {
      return '';
    }
    return data.averageDiscountPerc.toStringAsFixed(2) + ' %';
  }

  Widget _getAverageBidAmount() {
    if (data == null || data == null) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Average Bid',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            data == null ? '0' : '${getFormattedAmount('${data}', context)}',
            style: Styles.blackSmall,
          ),
        ),
      ],
    );
  }

  double totalUnsettledBids() {
    var t = 0.00;
    if (data == null) {
      return 0.0;
    }

    data.unsettledBids.forEach((b) {
      t += b.amount;
    });
    return data.totalUnsettledAmount;
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      print(' ♻️  ♻️  ♻️  build - dashboardData is null  ♻️  ♻️  ♻️ ');
      return Container();
    } else {
      print(' ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️  ♻️ ');
    }

    return Card(
      elevation: elevation == null ? 2.0 : elevation,
      color: Colors.brown.shade50,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: data == null ? Container() : _getTotalBids(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 20.0),
            child: data == null ? Container() : _getTotalBidValue(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: data == null ? Container() : _getAverageBidAmount(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: data == null ? Container() : _getAverageDiscount(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Unsettled  Bids',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  data == null || data == null
                      ? '0'
                      : '${getFormattedNumber(data.totalUnsettledBids, context)}',
                  style: Styles.blackSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 5.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Unsettled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  data == null || data.totalUnsettledAmount == null
                      ? '0.00'
                      : '${getFormattedAmount('${data.totalUnsettledAmount}', context)}',
                  style: Styles.pinkBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Settled  Bids',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  data == null ? '0' : '${getTotalSettledBids()}',
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Settled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  data == null
                      ? '0.00'
                      : '${getFormattedAmount('${data.totalSettledAmount}', context)}',
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: RaisedButton(
              elevation: 6.0,
              color: Theme.of(context).primaryColor,
              onPressed: _onStartCharts,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Show Charts',
                  style: Styles.whiteSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getTotalUnsettledBids() {
    if (data == null) {
      return '0';
    }
    return getFormattedNumber(data.unsettledBids.length, context);
  }

  String getTotalSettledBids() {
    if (data == null) {
      return '0';
    }
    return getFormattedNumber(data.settledBids.length, context);
  }

  void _onStartCharts() {
    if (listener != null) {
      listener.onCharts();
    }
  }
}

abstract class InvestorCardListener {
  onRefresh();
  onCharts();
}
