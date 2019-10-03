part of swagger.api;

class ChaincodeID {
  /* Chaincode location in the file system. This value is required by the deploy transaction. */
  String path = null;
  
/* Chaincode name identifier. This value is required by the invoke and query transactions. */
  String name = null;
  
  ChaincodeID();

  @override
  String toString() {
    return 'ChaincodeID[path=$path, name=$name, ]';
  }

  ChaincodeID.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    path =
        json['path']
    ;
    name =
        json['name']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name
     };
  }

  static List<ChaincodeID> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeID>() : json.map((value) => new ChaincodeID.fromJson(value)).toList();
  }

  static Map<String, ChaincodeID> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeID>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeID.fromJson(value));
    }
    return map;
  }
}

