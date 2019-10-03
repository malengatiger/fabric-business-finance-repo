part of swagger.api;

class PeerID {
  /* Name which uniquely identifies a network peer. */
  String name = null;
  
  PeerID();

  @override
  String toString() {
    return 'PeerID[name=$name, ]';
  }

  PeerID.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    name =
        json['name']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name
     };
  }

  static List<PeerID> listFromJson(List<dynamic> json) {
    return json == null ? new List<PeerID>() : json.map((value) => new PeerID.fromJson(value)).toList();
  }

  static Map<String, PeerID> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, PeerID>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new PeerID.fromJson(value));
    }
    return map;
  }
}

