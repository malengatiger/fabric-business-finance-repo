part of swagger.api;

class BlockchainInfo {
  /* Current height of the blockchain. */
  int height = null;
  
/* Hash of the last block in the blockchain. */
  String currentBlockHash = null;
  
/* Hash of the previous block in the blockchain. */
  String previousBlockHash = null;
  
  BlockchainInfo();

  @override
  String toString() {
    return 'BlockchainInfo[height=$height, currentBlockHash=$currentBlockHash, previousBlockHash=$previousBlockHash, ]';
  }

  BlockchainInfo.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    height =
        json['height']
    ;
    currentBlockHash =
        json['currentBlockHash']
    ;
    previousBlockHash =
        json['previousBlockHash']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'currentBlockHash': currentBlockHash,
      'previousBlockHash': previousBlockHash
     };
  }

  static List<BlockchainInfo> listFromJson(List<dynamic> json) {
    return json == null ? new List<BlockchainInfo>() : json.map((value) => new BlockchainInfo.fromJson(value)).toList();
  }

  static Map<String, BlockchainInfo> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, BlockchainInfo>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new BlockchainInfo.fromJson(value));
    }
    return map;
  }
}

