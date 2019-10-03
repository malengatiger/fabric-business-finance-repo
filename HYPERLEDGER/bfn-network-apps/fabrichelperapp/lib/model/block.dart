part of swagger.api;

class Block {
  /* Creator/originator of the block. */
  String proposerID = null;
  
/* Time of block creation. */
  Timestamp timestamp = null;
  

  List<Transaction> transactions = [];
  
/* Global state hash after executing all transactions in the block. */
  String stateHash = null;
  
/* Hash of the previous block in the blockchain. */
  String previousBlockHash = null;
  
/* Metadata required for consensus. */
  String consensusMetadata = null;
  
/* Data stored in the block, but excluded from the computation of block hash. */
  String nonHashData = null;
  
  Block();

  @override
  String toString() {
    return 'Block[proposerID=$proposerID, timestamp=$timestamp, transactions=$transactions, stateHash=$stateHash, previousBlockHash=$previousBlockHash, consensusMetadata=$consensusMetadata, nonHashData=$nonHashData, ]';
  }

  Block.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    proposerID =
        json['proposerID']
    ;
    timestamp =
      
      
      new Timestamp.fromJson(json['timestamp'])
;
    transactions =
      Transaction.listFromJson(json['transactions'])
;
    stateHash =
        json['stateHash']
    ;
    previousBlockHash =
        json['previousBlockHash']
    ;
    consensusMetadata =
        json['consensusMetadata']
    ;
    nonHashData =
        json['nonHashData']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'proposerID': proposerID,
      'timestamp': timestamp,
      'transactions': transactions,
      'stateHash': stateHash,
      'previousBlockHash': previousBlockHash,
      'consensusMetadata': consensusMetadata,
      'nonHashData': nonHashData
     };
  }

  static List<Block> listFromJson(List<dynamic> json) {
    return json == null ? new List<Block>() : json.map((value) => new Block.fromJson(value)).toList();
  }

  static Map<String, Block> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, Block>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new Block.fromJson(value));
    }
    return map;
  }
}

