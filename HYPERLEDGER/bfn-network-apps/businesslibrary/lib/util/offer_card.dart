import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final int number;
  final double elevation;
  final bool showSupplier, showCustomer;
  final Color color;

  OfferCard(
      {this.offer,
      this.number,
      this.elevation,
      this.showCustomer,
      this.color,
      this.showSupplier});

  TextStyle getTextStyle() {
    if (offer.dateClosed == null) {
      return TextStyle(
          color: Colors.teal, fontSize: 20.0, fontWeight: FontWeight.bold);
    } else {
      return TextStyle(
          color: Colors.pink, fontSize: 14.0, fontWeight: FontWeight.normal);
    }
  }

  Widget _getStatus() {
    if (offer.isOpen == true) {
      return Text(
        'Open',
        style: Styles.pinkBoldSmall,
      );
    } else {
      return Text(
        'Closed',
        style: Styles.greyLabelSmall,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 2.0 : elevation,
      color: color == null ? Colors.white : color,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30.0,
                    child: Text(
                      offer.itemNumber == null ? '0' : '${offer.itemNumber}',
                      style: Styles.blackBoldSmall,
                    ),
                  ),
                  Text(
                    getFormattedDateLongWithTime(offer.date, context),
                    style: Styles.blackSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: _getStatus(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      getFormattedAmount('${offer.offerAmount}', context),
                      style: Styles.tealBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            showCustomer == false
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, top: 4.0, bottom: 0.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 80.0,
                            child: Text(
                              'Customer',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            child: Text(
                              offer.customerName == null
                                  ? ''
                                  : offer.customerName,
                              overflow: TextOverflow.clip,
                              style: Styles.blackBoldSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            showSupplier == false
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 80.0,
                            child: Text(
                              'Supplier',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                        ),
                        Text(
                          offer.supplierName == null
                              ? '  '
                              : offer.supplierName,
                          style: Styles.blackSmall,
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 4.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 80.0,
                      child: Text(
                        'Discount',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                  ),
                  Text(
                    offer.discountPercent == null
                        ? '0.0 %'
                        : '${offer.discountPercent} %',
                    style: Styles.blackBoldSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 4.0, bottom: 0.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 80.0,
                      child: Text(
                        'Start',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                  ),
                  Text(
                    offer.startTime == null
                        ? 'N/A'
                        : '${getFormattedDateShort(offer.startTime, context)}',
                    style: Styles.blackSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 4.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 80.0,
                      child: Text(
                        'End',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                  ),
                  Text(
                    offer.endTime == null
                        ? 'N/A'
                        : '${getFormattedDateShort(offer.endTime, context)}',
                    style: Styles.blackBoldSmall,
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
