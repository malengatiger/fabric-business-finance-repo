part of swagger.api;

class PeerEndpoint {
  /* Unique peer identifier. */
  PeerID ID = null;
  
/* ipaddress:port combination identifying a network peer. */
  String address = null;
  
/* Network peer type. */
  String type = null;
  //enum typeEnum {  UNDEFINED,  VALIDATOR,  NON_VALIDATOR,  };
/* PKI identifier for the network peer. */
  String pkiID = null;
  
  PeerEndpoint();

  @override
  String toString() {
    return 'PeerEndpoint[ID=$ID, address=$address, type=$type, pkiID=$pkiID, ]';
  }

  PeerEndpoint.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    ID =
      
      
      new PeerID.fromJson(json['ID'])
;
    address =
        json['address']
    ;
    type =
        json['type']
    ;
    pkiID =
        json['pkiID']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'address': address,
      'type': type,
      'pkiID': pkiID
     };
  }

  static List<PeerEndpoint> listFromJson(List<dynamic> json) {
    return json == null ? new List<PeerEndpoint>() : json.map((value) => new PeerEndpoint.fromJson(value)).toList();
  }

  static Map<String, PeerEndpoint> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, PeerEndpoint>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new PeerEndpoint.fromJson(value));
    }
    return map;
  }
}

