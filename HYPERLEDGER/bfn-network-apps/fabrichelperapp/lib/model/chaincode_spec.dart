part of swagger.api;

class ChaincodeSpec {
  /* Chaincode specification language. */
  int type = null;
  
/* Unique Chaincode identifier. */
  ChaincodeID chaincodeID = null;
  
/* Specific function to execute within the Chaincode. */
  ChaincodeInput ctorMsg = null;
  
/* Username when security is enabled. */
  String secureContext = null;
  
/* Confidentiality level of the Chaincode. */
  ConfidentialityLevel confidentialityLevel = null;
  
  ChaincodeSpec();

  @override
  String toString() {
    return 'ChaincodeSpec[type=$type, chaincodeID=$chaincodeID, ctorMsg=$ctorMsg, secureContext=$secureContext, confidentialityLevel=$confidentialityLevel, ]';
  }

  ChaincodeSpec.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    type =
        json['type']
    ;
    chaincodeID =
      
      
      new ChaincodeID.fromJson(json['chaincodeID'])
;
    ctorMsg =
      
      
      new ChaincodeInput.fromJson(json['ctorMsg'])
;
    secureContext =
        json['secureContext']
    ;
    confidentialityLevel =
      
      
      new ConfidentialityLevel.fromJson(json['confidentialityLevel'])
;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'chaincodeID': chaincodeID,
      'ctorMsg': ctorMsg,
      'secureContext': secureContext,
      'confidentialityLevel': confidentialityLevel
     };
  }

  static List<ChaincodeSpec> listFromJson(List<dynamic> json) {
    return json == null ? new List<ChaincodeSpec>() : json.map((value) => new ChaincodeSpec.fromJson(value)).toList();
  }

  static Map<String, ChaincodeSpec> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, ChaincodeSpec>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new ChaincodeSpec.fromJson(value));
    }
    return map;
  }
}

