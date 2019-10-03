part of swagger.api;

class Secret {
  /* User enrollment id registered with the certificate authority. */
  String enrollId = null;
  
/* User enrollment password registered with the certificate authority. */
  String enrollSecret = null;
  
  Secret();

  @override
  String toString() {
    return 'Secret[enrollId=$enrollId, enrollSecret=$enrollSecret, ]';
  }

  Secret.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    enrollId =
        json['enrollId']
    ;
    enrollSecret =
        json['enrollSecret']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollId': enrollId,
      'enrollSecret': enrollSecret
     };
  }

  static List<Secret> listFromJson(List<dynamic> json) {
    return json == null ? new List<Secret>() : json.map((value) => new Secret.fromJson(value)).toList();
  }

  static Map<String, Secret> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, Secret>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new Secret.fromJson(value));
    }
    return map;
  }
}

