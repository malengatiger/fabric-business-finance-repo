part of swagger.api;

class PeersMessage {
  
  List<PeerEndpoint> peers = [];
  
  PeersMessage();

  @override
  String toString() {
    return 'PeersMessage[peers=$peers, ]';
  }

  PeersMessage.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    peers =
      PeerEndpoint.listFromJson(json['peers'])
;
  }

  Map<String, dynamic> toJson() {
    return {
      'peers': peers
     };
  }

  static List<PeersMessage> listFromJson(List<dynamic> json) {
    return json == null ? new List<PeersMessage>() : json.map((value) => new PeersMessage.fromJson(value)).toList();
  }

  static Map<String, PeersMessage> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, PeersMessage>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new PeersMessage.fromJson(value));
    }
    return map;
  }
}

