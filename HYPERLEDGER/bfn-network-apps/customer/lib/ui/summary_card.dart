import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

///summary card used in dashboards
class SummaryCard extends StatelessWidget {
  final int total;
  final String label;
  final TextStyle totalStyle, totalValueStyle;
  final double totalValue, elevation, height;
  final Color color;

  SummaryCard(
      {this.total,
      this.totalStyle,
      this.label,
      this.height,
      this.totalValue,
      this.totalValueStyle,
      this.color,
      this.elevation});

  @override
  Widget build(BuildContext context) {
    var top = 10.0;

    return new Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
      child: Card(
        elevation: elevation == null ? 6.0 : elevation,
        color: color == null ? Colors.white : color,
        child: Column(
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.only(top: top),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    style: Styles.greyLabelSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      '$total',
                      style: totalStyle == null
                          ? Styles.blackBoldLarge
                          : totalStyle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Total Value:',
                    style: Styles.greyLabelSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                    child: Text(
                      totalValue == null
                          ? '000,000.00'
                          : '${getFormattedAmount('$totalValue', context)}',
                      style: totalValueStyle == null
                          ? Styles.blackSmall
                          : totalValueStyle,
                    ),
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
