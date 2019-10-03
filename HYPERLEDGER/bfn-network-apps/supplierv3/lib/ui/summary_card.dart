import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

///summary card used in dashboards
class SummaryCard extends StatelessWidget {
  final int totalCount;
  final double totalValue, elevation;
  final String totalCountLabel, totalValueLabel;
  final TextStyle totalCountStyle, totalValueStyle;
  final Color color;

  SummaryCard(
      {this.totalCount,
      this.totalValue,
      this.totalCountLabel,
      this.totalValueLabel,
      this.elevation,
      this.totalCountStyle,
      this.color,
      this.totalValueStyle});

  @override
  Widget build(BuildContext context) {
    var height = 96.0, top = 8.0;

    return new Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 4.0),
      child: Card(
        elevation: elevation == null ? 2.0 : elevation,
        color: color == null ? Colors.white : color,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10.0, top: 16.0, right: 10.0, bottom: 16.0),
          child: Column(
            children: <Widget>[
              totalCount == null
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          totalCountLabel == null ? '' : totalCountLabel,
                          style: Styles.greyLabelMedium,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text(
                            '$totalCount',
                            style: totalCountStyle == null
                                ? Styles.pinkBoldReallyLarge
                                : totalCountStyle,
                          ),
                        ),
                      ],
                    ),
              totalValue == null
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            totalValueLabel == null
                                ? 'Total Value'
                                : totalValueLabel,
                            style: Styles.greyLabelSmall,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text(
                              totalValue == null
                                  ? ''
                                  : '${getFormattedAmount('$totalValue', context)}',
                              style: totalValueStyle == null
                                  ? Styles.blackBoldSmall
                                  : totalValueStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
