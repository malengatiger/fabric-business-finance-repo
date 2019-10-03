class Sector {
  String sectorId, sectorName, description;

  Sector({this.sectorId, this.sectorName, this.description});

  Sector.fromJson(Map data) {
    this.sectorId = data['sectorId'];
    this.sectorName = data['sectorName'];
    this.description = data['description'];
  }
  Map<String, String> toJson() => <String, String>{
        'sectorId': sectorId,
        'sectorName': sectorName,
        'description': description,
      };
}
