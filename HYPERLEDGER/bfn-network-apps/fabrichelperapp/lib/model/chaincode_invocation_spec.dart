part of swagger.api;

class ChaincodeInvocationSpec {
  /* Chaincode specification message. */
  ChaincodeSpec chaincodeSpec = null;
  
  ChaincodeInvocationSpec();

  @override
  String toString() {
    return 'ChaincodeInvocationSpec[chaincodeSpec=$chaincodeSpec, ]';
  }

  ChaincodeInvocationSpec.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    chaincodeSpec =
      
      
      new ChaincodeSpec.fromJson(json['chaincodeSpec'])
;
  }

  Map<String, dynamic> toJson() {
    return {
      'chaincodeSpec': chaincodeSpec
     };
  }

  static List<ChaincodeInvocationSpec> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeInvocationSpec>() : json.map((value) => new ChaincodeInvocationSpec.fromJson(value)).toList();
  }

  static Map<String, ChaincodeInvocationSpec> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeInvocationSpec>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeInvocationSpec.fromJson(value));
    }
    return map;
  }
}

