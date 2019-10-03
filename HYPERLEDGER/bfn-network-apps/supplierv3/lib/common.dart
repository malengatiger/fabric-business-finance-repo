import 'package:businesslibrary/util/selectors.dart';
import 'package:flutter/material.dart';

abstract class DiscountListener {
  onDiscount(String discount);
}
List<DropdownMenuItem<String>> items = List();
DiscountListener mListener;

Widget getDiscountDropDown(DiscountListener listener) {
  print('_getDiscountDropDownItems._buildList................');
  mListener = listener;
  if (items.isEmpty) {
    buildList();
  }
  return DropdownButton<String>(
    items: items,
    hint: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Discount Percentage'),
    ),
    onChanged: _onChanged,
  );

}
buildList() {
  var item6 = DropdownMenuItem<String>(
    value: '1.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('1 %'),
      ],
    ),
  );
  items.add(item6);

  var item7 = DropdownMenuItem<String>(
    value: '2.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('2 %'),
      ],
    ),
  );
  items.add(item7);

  var item8 = DropdownMenuItem<String>(
    value: '3.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('3 %'),
      ],
    ),
  );
  items.add(item8);

  var item9 = DropdownMenuItem<String>(
    value: '4.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('4 %'),
      ],
    ),
  );
  items.add(item9);

  var item10 = DropdownMenuItem<String>(
    value: '5.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('5 %'),
      ],
    ),
  );
  items.add(item10);

  var item11 = DropdownMenuItem<String>(
    value: '6.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('6 %'),
      ],
    ),
  );
  items.add(item11);

  var item12 = DropdownMenuItem<String>(
    value: '7.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('7 %'),
      ],
    ),
  );
  items.add(item12);

  var item13 = DropdownMenuItem<String>(
    value: '8.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('8 %'),
      ],
    ),
  );
  items.add(item13);

  var item14 = DropdownMenuItem<String>(
    value: '9.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('9 %'),
      ],
    ),
  );
  items.add(item14);
  var item15 = DropdownMenuItem<String>(
    value: '10.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('10 %'),
      ],
    ),
  );
  items.add(item15);
  var item16 = DropdownMenuItem<String>(
    value: '11.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('11 %'),
      ],
    ),
  );
  items.add(item16);
  var item17 = DropdownMenuItem<String>(
    value: '12.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('12 %'),
      ],
    ),
  );
  items.add(item17);
  var item18 = DropdownMenuItem<String>(
    value: '13.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('13 %'),
      ],
    ),
  );
  items.add(item18);
  var item19 = DropdownMenuItem<String>(
    value: '14.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('14 %'),
      ],
    ),
  );
  items.add(item19);
  var x1 = DropdownMenuItem<String>(
    value: '15.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('15 %'),
      ],
    ),
  );
  items.add(x1);
  var x2 = DropdownMenuItem<String>(
    value: '16.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('16 %'),
      ],
    ),
  );
  items.add(x2);
  var x3 = DropdownMenuItem<String>(
    value: '17.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('17 %'),
      ],
    ),
  );
  items.add(x3);
  var x4 = DropdownMenuItem<String>(
    value: '18.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('18 %'),
      ],
    ),
  );
  items.add(x4);
  var x5 = DropdownMenuItem<String>(
    value: '19.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('19 %'),
      ],
    ),
  );
  items.add(x5);
  var x6 = DropdownMenuItem<String>(
    value: '20.0',
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.apps,
            color: getRandomColor(),
          ),
        ),
        Text('20 %'),
      ],
    ),
  );
  items.add(x6);
}

void _onChanged(String value) {
  print('_getDiscountDropDownItems - discount selected: $value. Telling listener');
  mListener.onDiscount(value);
}
