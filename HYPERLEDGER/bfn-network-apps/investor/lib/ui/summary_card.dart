import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:investor/bloc/bloc.dart';

class DashboardCard extends StatelessWidget {
  final Bloc bloc;
  final Color color;
  final double elevation;

  DashboardCard({@required this.bloc, this.color, this.elevation});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardData>(
      initialData: DashboardData(),
      stream: bloc.dashboardStream,
      builder: (context, snapshot) {
        DashboardData data;
        print('🔑 🔑 snapshot.connectionState ${snapshot.connectionState}');
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            data = snapshot.data;
            break;
          case ConnectionState.done:
            break;
          case ConnectionState.waiting:
            break;
          case ConnectionState.none:
            break;
        }
        if (data == null) {
          return Container();
        } else {
          return Card(
            elevation: elevation == null ? 0.0 : elevation,
            color: color == null ? Colors.white : color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  _getTotalBids(data, context),
                  _getTotalBidAmount(data, context),
                  _getAverageBidAmount(data, context),
                  _getAverageDiscount(data, context),
                  Padding(padding: const EdgeInsets.all(8.0)),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _getTotalBids(DashboardData data, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              '# Bids Made: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              data == null
                  ? '0'
                  : '${getFormattedNumber(data.totalBids, context)}',
              style: Styles.blackBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTotalBidAmount(DashboardData data, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              '# Total Amount',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              data == null
                  ? '0'
                  : '${getFormattedAmount('${data.totalBidAmount}', context)}',
              style: Styles.purpleBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAverageDiscount(DashboardData data, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              '# Avg Discount',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              data == null
                  ? '0'
                  : '${getFormattedAmount('${data.averageDiscountPerc} %', context)}',
              style: Styles.blackBoldSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAverageBidAmount(DashboardData data, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              '# Average Bid',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              data == null
                  ? '0'
                  : '${getFormattedAmount('${data.averageBidAmount}', context)}',
              style: Styles.blackBoldSmall,
            ),
          ),
        ],
      ),
    );
  }
}
