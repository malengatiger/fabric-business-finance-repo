import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class BasePager {
  final int pageLimit;
  final List<Findable> items;
  int currentIndex = 0;
  Pages pages = Pages();
  List<Findable> currentPage = List();
  int _pageNumber = 1, _totalPages = 0, startKey;

  int get pageNumber => _pageNumber;
  int get totalPages => _totalPages;

  BasePager({this.pageLimit, this.items}) {
    _buildPages();
  }

  List<Findable> getFirstPage() {
    _pageNumber = 1;
    currentIndex = 0;
    var m = pages.getPage(currentIndex);
    if (m == null) {
      return List();
    }
    currentPage = pages.getPage(currentIndex).items;
    print('BasePager.getFirstPage ############# currentIndex: $currentIndex');
    return currentPage;
  }

  List<Findable> getNextPage() {
    currentIndex++;
    _pageNumber++;
    print(
        'BasePager.getNextPage: _pageNumber: $_pageNumber currentIndex: $currentIndex');
    if (_pageNumber > pages._pages.length) {
      print(
          'BasePager._forwardPressed ... hey Toto, we not in Kansas nomore ....pageNumber: $_pageNumber');
      _pageNumber = 1;
      startKey = null;
      currentIndex = 0;
    }
    var m = pages.getPage(currentIndex);
    if (m == null) {
      return List();
    }
    currentPage = pages.getPage(currentIndex).items;
    return currentPage;
  }

  List<Findable> getPreviousPage() {
    print(
        '\n\n_BasePager._backPressed currentIndex: $currentIndex at the top, pageNumber: $_pageNumber - BEFORE');
    currentIndex--;
    _pageNumber--;

    if (_pageNumber == 0) {
      _pageNumber = 1;
      currentIndex = 0;
      print('BasePager.backPressed ...... cant go back in time, Jojo Kiss!');
      return null;
    }

    if (currentIndex < 0) {
      currentIndex = 0;
    }

    print(
        '_BasePager._backPressed currentIndex: $currentIndex after process, , pageNumber: $_pageNumber - about to get page');
    var m = pages.getPage(currentIndex);
    if (m == null) {
      return List();
    }
    currentPage = pages.getPage(currentIndex).items;
    return currentPage;
  }

  List<Findable> getAllPages() {
    return pages.getAllPages();
  }

  void _buildPages() {
    /////
    if (items == null) {
      return;
    }
    var rem = items.length % pageLimit;
    _totalPages = items.length ~/ pageLimit;
    if (rem > 0) {
      _totalPages++;
    }
    startKey = null;
    currentIndex = 0;
    _pageNumber = 1;

    for (var i = 0; i < _totalPages; i++) {
      //build page
      var result =
          Finder.find(intDate: startKey, pageLimit: pageLimit, baseList: items);
      var page = Page(
          index: currentIndex, pageNumber: _pageNumber, items: result.items);
      pages.addPage(page);
      currentIndex++;
      _pageNumber++;
      startKey = result.startKey;
    }
    pages.doPrint();
  }

  void doPrint() {
    print('\n\nBasePager.doPrint ################### print current page');
    if (currentPage.isEmpty) {
      print('BasePager.doPrint - current page is empty');
      return;
    }
    int count = 1;
    currentPage.forEach((f) {
      if (f is InvoiceBid) {
        prettyPrint(f.toJson(), '## CURRENT PAGE row: $count');
        count++;
      }
    });
    print('\nBasePager.doPrint ################### end of current page\n\n');
  }
}

abstract class PagerControlListener {
  onNextPageRequired();
  onPreviousPageRequired();
  onPageLimit(int pageLimit);
}

class Page {
  final int pageNumber;
  final int index;
  final List<Findable> items;

  Page({this.pageNumber, this.items, this.index});
}

class Pages {
  List<Page> _pages = List();
  List<Page> get allPages => _pages;
  void addPage(Page page) {
    _pages.add(page);
  }

  Page getPage(int index) {
    print('Pages.getPage ........... index: $index');
    if (_pages.isEmpty) {
      print(
          'Pages.getPage ------------ _pages.isEmpty. QUIT, return null page ...');

      return null;
    }
    var page = _pages.elementAt(index);
    print(
        'Pages.getPage ###### items in new page: ${page.items.length}. check if 0');
    page.items.forEach((i) {
      if (i is Offer) {
        print(
            'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.offerAmount}');
      }
      if (i is PurchaseOrder) {
        print(
            'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.purchaserName} ${i.amount}');
      }
      if (i is DeliveryNote) {
        print(
            'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
      }
      if (i is Invoice) {
        print(
            'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
      }
      if (i is InvoiceBid) {
        print(
            'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.investorName} reservePercent: ${i.reservePercent} ${i.amount}');
      }
      if (i is InvestorInvoiceSettlement) {
        print(
            'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.investorName} supplier: ${i.supplierName} ${i.amount}');
      }
    });
    return page;
  }

  List<Findable> getAllPages() {
    List<Findable> list = List();
    _pages.forEach((page) {
      page.items.forEach((i) {
        list.add(i);
      });
    });
    return list;
  }

  doPrint() {
    print('\n\n##############################################');
    print('Pages.doPrint .... pages: ${_pages.length}');
//    _pages.forEach((p) {
//      print('\n\npageNumber: ${p.pageNumber} items: ${p.items.length}');
//      p.items.forEach((i) {
//        if (i is Offer) {
//          print(
//              'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.offerAmount}');
//        }
//        if (i is PurchaseOrder) {
//          print(
//              'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.purchaserName} ${i.amount}');
//        }
//        if (i is DeliveryNote) {
//          print(
//              'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
//        }
//        if (i is Invoice) {
//          print(
//              'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
//        }
//        if (i is InvoiceBid) {
//          print(
//              'itemNumber: 🍑  ${i.itemNumber} ${i.intDate} ${i.date} ${i.investorName} reservePercent: ${i.reservePercent} ${i.amount}');
//        }
//      });
//    });
//    print('\n##############################################\n\n');
  }
}

class PagerControl extends StatelessWidget {
  final int items;
  final int pageNumber;
  final String itemName;
  final int pageLimit;
  final double elevation;
  final Color color;
  final PagerControlListener listener;

  PagerControl(
      {this.color,
      this.pageNumber,
      this.itemName,
      this.pageLimit,
      this.items,
      this.listener,
      this.elevation}) {
    _buildNumberItems();
  }

  static const numbers = [2, 4, 6, 8, 10, 20];
  final List<DropdownMenuItem<int>> dropDownItems = List();

  int _getTotalPages() {
    var t = 0;
    var rem = items % pageLimit;
    t = items ~/ pageLimit;
    if (rem > 0) {
      t++;
    }
    return t;
  }

  void _onNextPage() {
    print('\n\nPagerControl._onNextPage\n');
    listener.onNextPageRequired();
  }

  void _onPreviousPage() {
    print('\n\nPagerControl._onPreviousPage\n');
    listener.onPreviousPageRequired();
  }

  void _buildNumberItems() {
    numbers.forEach((num) {
      var item = DropdownMenuItem<int>(
        value: num,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Text('$num'),
          ],
        ),
      );
      dropDownItems.add(item);
    });
  }

  void _onNumber(int value) async {
    print(
        '\n\nPager._onNumber #################---------------> value: $value');
    if (pageLimit == value) {
      return;
    }
    await SharedPrefs.savePageLimit(value);
    listener.onPageLimit(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 8.0 : elevation,
      color: color == null ? Styles.white : color,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 2.0, top: 4.0),
            child: Row(
              children: <Widget>[
                DropdownButton<int>(
                  items: dropDownItems,
                  hint: Text(
                    'Per Page',
                    style: Styles.blackSmall,
                  ),
                  onChanged: _onNumber,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                  child: Text(
                    '$pageLimit',
                    style: Styles.pinkBoldSmall,
                  ),
                ),
                GestureDetector(
                  onTap: _onPreviousPage,
                  child: Row(
                    children: <Widget>[
                      Text('Back', style: Styles.blackSmall),
                      IconButton(
                        icon: Icon(
                          Icons.fast_rewind,
                          color: Colors.black,
                          size: 36.0,
                        ),
                        onPressed: _onPreviousPage,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: _onNextPage,
                    child: Row(
                      children: <Widget>[
                        Text('Next', style: Styles.blackSmall),
                        IconButton(
                          icon: Icon(
                            Icons.fast_forward,
                            color: Colors.black,
                            size: 36.0,
                          ),
                          onPressed: _onNextPage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, top: 10.0),
            child: Row(
              children: <Widget>[
                Text(
                  "Page",
                  style: Styles.blueSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '$pageNumber',
                    style: Styles.blackSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'of',
                    style: Styles.blueSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                  child: Text(
                    '${_getTotalPages()}',
                    style: Styles.blackSmall,
                  ),
                ),
                Text(
                  '$items',
                  style: Styles.pinkBoldSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    itemName,
                    style: Styles.blackSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PagingTotalsView extends StatelessWidget {
  final double pageValue, totalValue;
  final TextStyle totalValueStyle, pageValueStyle, labelStyle;

  PagingTotalsView(
      {this.pageValue,
      this.totalValueStyle,
      this.pageValueStyle,
      this.totalValue,
      this.labelStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
          child: Row(
            children: <Widget>[
              Text(
                'Total Value:',
                style: labelStyle == null ? Styles.greyLabelSmall : labelStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${getFormattedAmount('$totalValue', context)}',
                  style: totalValueStyle == null
                      ? Styles.brownBoldMedium
                      : totalValueStyle,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              Text(
                'Page Value:',
                style: labelStyle == null ? Styles.greyLabelSmall : labelStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  pageValue == null
                      ? '0.00'
                      : getFormattedAmount('$pageValue', context),
                  style: pageValueStyle == null
                      ? Styles.blackBoldMedium
                      : pageValueStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
