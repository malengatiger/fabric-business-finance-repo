part of swagger.api;

class ChaincodeOpFailure {
  /* A string specifying the version of the JSON-RPC protocol. Must be exactly '2.0'. */
  String jsonrpc = null;
  
/* A structured value specifying the code and description of the error that occurred. */
  RpcError error = null;
  
/* This number will be the same as the value of the id member in the request object. If there was an error detecting the id in the request object (e.g. Parse error/Invalid Request), it will be null. */
  int id = 123;
  
  ChaincodeOpFailure();

  @override
  String toString() {
    return 'ChaincodeOpFailure[jsonrpc=$jsonrpc, error=$error, id=$id, ]';
  }

  ChaincodeOpFailure.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    jsonrpc =
        json['jsonrpc']
    ;
    error =
      
      
      new RpcError.fromJson(json['error'])
;
    id =
        json['id']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'error': error,
      'id': id
     };
  }

  static List<ChaincodeOpFailure> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeOpFailure>() : json.map((value) => new ChaincodeOpFailure.fromJson(value)).toList();
  }

  static Map<String, ChaincodeOpFailure> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeOpFailure>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeOpFailure.fromJson(value));
    }
    return map;
  }
}

