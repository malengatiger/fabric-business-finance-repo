part of swagger.api;

class ChaincodeInput {
  /* Arguments supplied to the Chaincode function. */
  List<String> args = [];
  
  ChaincodeInput();

  @override
  String toString() {
    return 'ChaincodeInput[args=$args, ]';
  }

  ChaincodeInput.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    args =
        (json['args'] as List).map((item) => item as String).toList()
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'args': args
     };
  }

  static List<ChaincodeInput> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeInput>() : json.map((value) => new ChaincodeInput.fromJson(value)).toList();
  }

  static Map<String, ChaincodeInput> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeInput>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeInput.fromJson(value));
    }
    return map;
  }
}

