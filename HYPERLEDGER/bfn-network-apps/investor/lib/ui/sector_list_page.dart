import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class SectorListPage extends StatefulWidget {
  final InvestorProfile profile;

  const SectorListPage({this.profile});
  @override
  _SectorListPageState createState() => _SectorListPageState();
}

class _SectorListPageState extends State<SectorListPage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Sector> sectors, selectedSectors = List();
  InvestorProfile profile;
  @override
  void initState() {
    super.initState();
    _getSectors();
  }

  void _getSectors() async {
    sectors = await ListAPI.getSectors();
    if (profile != null) {
      prettyPrint(profile.toJson(), '_getSectors profile');
      if (profile.sectors != null && profile.sectors.isNotEmpty) {
        profile.sectors.forEach((supp) {
          sectors.forEach((s) {
            if (s.sectorId == supp.split('#').elementAt(1)) {
              selectedSectors.add(s);
            }
          });
        });
      }
    }
    print(
        '_SectorListPageState._getSectors selectedSectors: ${selectedSectors.length}');
    setState(() {});
  }

  _onDeleteSector(Sector sector) {
    selectedSectors.remove(sector);
    Navigator.pop(context);
    setState(() {});
    print(
        '_ProfilePageState._onDeleteSector - deleted supplier: ${sector.toJson()}');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: '${sector.sectorName} removed from list',
        textColor: Styles.white,
        backgroundColor: Styles.black);
  }

  _showSelectedSectors() {
    if (selectedSectors.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No sectors in your profile',
          listener: this,
          actionLabel: 'CLOSE');
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Column(
                children: <Widget>[
                  Text(
                    "Investor Sector List",
                    style: Styles.tealBoldMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Tap to Remove Sector",
                      style: Styles.pinkBoldSmall,
                    ),
                  ),
                ],
              ),
              content: Container(
                height: 200.0,
                child: ListView.builder(
                    itemCount:
                        selectedSectors == null ? 0 : selectedSectors.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        onTap: () {
                          _onDeleteSector(selectedSectors.elementAt(index));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.apps,
                                  color: Styles.teal,
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  child: Text(
                                    '${selectedSectors.elementAt(index).sectorName}',
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _ignore,
                  child: Text('Close'),
                ),
              ],
            ));
  }

  _ignore() {
    Navigator.pop(context);
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  Widget build(BuildContext context) {
    profile = widget.profile;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('BFN Investor Sectors'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 68.0),
                  child: Icon(
                    Icons.list,
                    color: Styles.white,
                  ),
                ),
                FlatButton(
                  onPressed: _showSelectedSectors,
                  child: Text(
                    'View Selected Sectors',
                    style: Styles.whiteMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                          if (sectors.isNotEmpty) {
                            _onSelected(sectors.elementAt(index));
                          }
                        },
                        child: new SectorCard(sectors.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFinish,
        elevation: 8.0,
        backgroundColor: Styles.purple,
        child: Icon(Icons.done),
      ),
    );
  }

  _onFinish() {
    print(
        '_SectorListPageState._onFinish selectedSectors: ${selectedSectors.length}');
    Navigator.pop(context, selectedSectors);
  }

  _showRemoveDialog(Sector sector) {
    this.sector = sector;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Sector Removal",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Styles.pink),
              ),
              content: Flexible(
                child: Container(
                  height: 60.0,
                  child: Text(
                    'Do you want to remove ${sector.sectorName} from your sector list?',
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onRemoveSector,
                  child: Text(
                    'REMOVE',
                    style: Styles.pinkBoldMedium,
                  ),
                ),
              ],
            ));
  }

  Sector sector;
  _showAddDialog(Sector supplier) {
    this.sector = supplier;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Sector Addition",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 60.0,
                child: Text(
                    'Do you want to add ${supplier.sectorName} to your sector list?'),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onAddSector,
                  child: Text('ADD SECTOR'),
                ),
              ],
            ));
  }

  _onSelected(Sector sector) {
    print('_SectorListPageState._onSelected selectted ${sector.sectorName}');
    bool isFound = false;
    selectedSectors.forEach((supp) {
      if (sector.sectorId == supp.sectorId) {
        isFound = true;
      }
    });
    if (isFound) {
      _showRemoveDialog(sector);
    } else {
      _showAddDialog(sector);
    }
  }

  void _onNoPressed() {
    Navigator.pop(context);
  }

  _onRemoveSector() {
    Navigator.pop(context);
    selectedSectors.remove(sector);
    print(
        '_SectorListPageState._onRemoveSector removed: ${sector.sectorName} selectedSectors: ${selectedSectors.length}');
    //setState(() {});
  }

  _onAddSector() {
    Navigator.pop(context);
    selectedSectors.add(sector);
    print(
        '_SectorListPageState._onAddSector added sector: ${sector.sectorName} selectedSectors: ${selectedSectors.length}');
    //setState(() {});
  }
}
