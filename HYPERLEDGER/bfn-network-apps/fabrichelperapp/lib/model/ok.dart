part of swagger.api;

class OK {
  /* A descriptive message confirming a successful request. */
  String OK = null;
  
/* An optional parameter containing additional information about the request. */
  String message = null;
  
  OK();

  @override
  String toString() {
    return 'OK[OK=$OK, message=$message, ]';
  }

  OK.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    OK =
        json['OK']
    ;
    message =
        json['message']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'OK': OK,
      'message': message
     };
  }

  static List<OK> listFromJson(List<dynamic> json) {
    return json == null ? new List<OK>() : json.map((value) => new OK.fromJson(value)).toList();
  }

  static Map<String, OK> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, OK>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new OK.fromJson(value));
    }
    return map;
  }
}

