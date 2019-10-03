import 'dart:io';
import 'dart:math';

import 'package:businesslibrary/api/file_util.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/country.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:flutter/material.dart';

class SectorSelectorPage extends StatefulWidget {
  @override
  _SectorSelectorPageState createState() => _SectorSelectorPageState();
}

class _SectorSelectorPageState extends State<SectorSelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Sector> sectors;
  @override
  initState() {
    super.initState();
    _getSectors();
  }

  _getSectors() async {
    sectors = await FileUtil.getSector();

    setState(() {});
    if (sectors == null) {
      sectors = await ListAPI.getSectors();
      if (sectors.isNotEmpty) {
        await FileUtil.saveSectors(Sectors(sectors));
        setState(() {});
      }
    }
  }

  String sectorType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sector Types'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: sectors == null ? 0 : sectors.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                        onTap: () {
                          var sector = sectors.elementAt(index);
                          print(
                              'SectorSelectorPage.build about to pop ${sector.sectorName}');
                          Navigator.pop(context, sector);
                        },
                        child: new SectorCard(sectors.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SectorCard extends StatelessWidget {
  final Sector sector;

  SectorCard(this.sector);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                sector.sectorName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

///////////////

class CountrySelectorPage extends StatefulWidget {
  @override
  _CountrySelectorPageState createState() => _CountrySelectorPageState();
}

class _CountrySelectorPageState extends State<CountrySelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Country> countries;
  @override
  initState() {
    super.initState();
    _getCountries();
  }

  _getCountries() async {
    countries = await ListAPI.getCountries();
    print(
        'CountrySelectorPage._getCountries found:countries ${countries.length}');
    setState(() {});
  }

  String countryName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Countries'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: countries == null ? 0 : countries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                        onTap: () {
                          var xType = countries.elementAt(index);
                          print(
                              'CountrySelectorPage.build about to pop ${xType.name}');
                          Navigator.pop(context, xType);
                        },
                        child: new CountryCard(countries.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class CountryCard extends StatelessWidget {
  final Country country;

  CountryCard(this.country);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  country.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///////
class SupplierSelectorPage extends StatefulWidget {
  @override
  _SupplierSelectorPageState createState() => _SupplierSelectorPageState();
}

class _SupplierSelectorPageState extends State<SupplierSelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Supplier> suppliers;
  @override
  initState() {
    super.initState();
    _getSuppliers();
  }

  _getSuppliers() async {
    suppliers = await ListAPI.getSuppliers();
    print(
        '🌺 🌺 🌺 SupplierSelectorPage.getSuppliers; found:suppliers 🌼 ${suppliers.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Supplier List'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: suppliers == null ? 0 : suppliers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                        onTap: () {
                          var supp = suppliers.elementAt(index);
                          print(
                              'SupplierSelectorPage.build about to pop ${supp.name}');
                          Navigator.pop(context, supp);
                        },
                        child: new SupplierCard(suppliers.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  final Supplier supplier;

  SupplierCard(this.supplier);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                supplier.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

List<Color> _colors = List();
Random _rand = Random(new DateTime.now().millisecondsSinceEpoch);
Color getRandomColor() {
  _colors.clear();
  _colors.add(Colors.blue);
  _colors.add(Colors.grey);
  _colors.add(Colors.black);
  _colors.add(Colors.pink);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.amber);
  _colors.add(Colors.indigo);
  _colors.add(Colors.lightBlue);
  _colors.add(Colors.lime);
  _colors.add(Colors.black);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.deepOrange);
  _colors.add(Colors.brown);
  _colors.add(Colors.cyan);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.blue);
  _colors.add(Colors.black);
  _colors.add(Colors.grey);
  _colors.add(Colors.black);
  _colors.add(Colors.pink);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.amber);
  _colors.add(Colors.indigo);
  _colors.add(Colors.lightBlue);
  _colors.add(Colors.lime);
  _colors.add(Colors.black);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.deepOrange);
  _colors.add(Colors.brown);
  _colors.add(Colors.cyan);
  _colors.add(Colors.teal);
  _colors.add(Colors.black);
  _colors.add(Colors.red);
  _colors.add(Colors.green);

  _rand = Random(DateTime.now().millisecondsSinceEpoch * _rand.nextInt(5));
  int index = _rand.nextInt(_colors.length - 1);
  sleep(const Duration(milliseconds: 2));
  return _colors.elementAt(index);
}

Color getRandomPastelColor() {
  print('getRandomColor ..........');
  _colors.clear();
//  _colors.add(Colors.blue.shade50);
//  _colors.add(Colors.grey.shade50);
  _colors.add(Colors.pink.shade50);
  _colors.add(Colors.teal.shade50);
//  _colors.add(Colors.red.shade50);
//  _colors.add(Colors.green.shade50);
//  _colors.add(Colors.amber.shade50);
  _colors.add(Colors.indigo.shade50);
//  _colors.add(Colors.lightBlue.shade50);
//  _colors.add(Colors.lime.shade50);
//  _colors.add(Colors.deepPurple.shade50);
//  _colors.add(Colors.deepOrange.shade50);
  _colors.add(Colors.brown.shade50);
//  _colors.add(Colors.cyan.shade50);

  _rand = Random(new DateTime.now().millisecondsSinceEpoch);
  int index = _rand.nextInt(_colors.length - 1);
  return _colors.elementAt(index);
}
