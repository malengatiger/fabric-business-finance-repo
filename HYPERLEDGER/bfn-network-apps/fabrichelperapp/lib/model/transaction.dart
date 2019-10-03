part of swagger.api;

class Transaction {
  /* Transaction type. */
  String type = null;
  //enum typeEnum {  UNDEFINED,  CHAINCODE_DEPLOY,  CHAINCODE_INVOKE,  CHAINCODE_QUERY,  CHAINCODE_TERMINATE,  };
/* Chaincode identifier as bytes. */
  String chaincodeID = null;
  
/* Payload supplied for Chaincode function execution. */
  String payload = null;
  
/* Unique transaction identifier. */
  String id = null;
  
/* Time at which the chanincode becomes executable. */
  Timestamp timestamp = null;
  
/* Confidentiality level of the Chaincode. */
  ConfidentialityLevel confidentialityLevel = null;
  
/* Nonce value generated for this transaction. */
  String nonce = null;
  
/* Certificate of client sending the transaction. */
  String cert = null;
  
/* Signature of client sending the transaction. */
  String signature = null;
  
  Transaction();

  @override
  String toString() {
    return 'Transaction[type=$type, chaincodeID=$chaincodeID, payload=$payload, id=$id, timestamp=$timestamp, confidentialityLevel=$confidentialityLevel, nonce=$nonce, cert=$cert, signature=$signature, ]';
  }

  Transaction.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    type =
        json['type']
    ;
    chaincodeID =
        json['chaincodeID']
    ;
    payload =
        json['payload']
    ;
    id =
        json['id']
    ;
    timestamp =
      
      
      new Timestamp.fromJson(json['timestamp'])
;
    confidentialityLevel =
      
      
      new ConfidentialityLevel.fromJson(json['confidentialityLevel'])
;
    nonce =
        json['nonce']
    ;
    cert =
        json['cert']
    ;
    signature =
        json['signature']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'chaincodeID': chaincodeID,
      'payload': payload,
      'id': id,
      'timestamp': timestamp,
      'confidentialityLevel': confidentialityLevel,
      'nonce': nonce,
      'cert': cert,
      'signature': signature
     };
  }

  static List<Transaction> listFromJson(List<dynamic> json) {
    return json == null ? new List<Transaction>() : json.map((value) => new Transaction.fromJson(value)).toList();
  }

  static Map<String, Transaction> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, Transaction>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new Transaction.fromJson(value));
    }
    return map;
  }
}

