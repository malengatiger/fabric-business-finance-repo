part of swagger.api;

class ChaincodeOpSuccess {
  /* A string specifying the version of the JSON-RPC protocol. Must be exactly '2.0'. */
  String jsonrpc = null;
  
/* The value of this element is determined by the method invoked on the server. */
  RpcResponse result = null;
  
/* This number will be the same as the value of the id member in the request object. */
  int id = 123;
  
  ChaincodeOpSuccess();

  @override
  String toString() {
    return 'ChaincodeOpSuccess[jsonrpc=$jsonrpc, result=$result, id=$id, ]';
  }

  ChaincodeOpSuccess.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    jsonrpc =
        json['jsonrpc']
    ;
    result =
      
      
      new RpcResponse.fromJson(json['result'])
;
    id =
        json['id']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'result': result,
      'id': id
     };
  }

  static List<ChaincodeOpSuccess> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeOpSuccess>() : json.map((value) => new ChaincodeOpSuccess.fromJson(value)).toList();
  }

  static Map<String, ChaincodeOpSuccess> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeOpSuccess>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeOpSuccess.fromJson(value));
    }
    return map;
  }
}

