part of swagger.api;

class ChaincodeOpPayload {
  /* A string specifying the version of the JSON-RPC protocol. Must be exactly '2.0'. */
  String jsonrpc = null;
  
/* A string containing the name of the method to be invoked. Must be 'deploy', 'invoke', or 'query'. */
  String method = null;
  
/* A required Chaincode specification message identifying the target chaincode. */
  ChaincodeSpec params = null;
  
/* An integer number used to correlate the request and response objects. If it is not included, the request is assumed to be a notification and the server will not generate a response. */
  int id = null;
  
  ChaincodeOpPayload();

  @override
  String toString() {
    return 'ChaincodeOpPayload[jsonrpc=$jsonrpc, method=$method, params=$params, id=$id, ]';
  }

  ChaincodeOpPayload.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    jsonrpc =
        json['jsonrpc']
    ;
    method =
        json['method']
    ;
    params =
      
      
      new ChaincodeSpec.fromJson(json['params'])
;
    id =
        json['id']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      'params': params,
      'id': id
     };
  }

  static List<ChaincodeOpPayload> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeOpPayload>() : json.map((value) => new ChaincodeOpPayload.fromJson(value)).toList();
  }

  static Map<String, ChaincodeOpPayload> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeOpPayload>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeOpPayload.fromJson(value));
    }
    return map;
  }
}

