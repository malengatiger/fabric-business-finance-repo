part of swagger.api;

class RpcError {
  /* A number that indicates the error type that occurred. */
  int code = -32700;
  
/* A string providing a short description of the error. */
  String message = null;
  
/* A primitive or structured value that contains additional information about the error (e.g. detailed error information, nested errors etc.). */
  String data = null;
  
  RpcError();

  @override
  String toString() {
    return 'RpcError[code=$code, message=$message, data=$data, ]';
  }

  RpcError.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    code =
        json['code']
    ;
    message =
        json['message']
    ;
    data =
        json['data']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data
     };
  }

  static List<RpcError> listFromJson(List<dynamic> json) {
    return json == null ? new List<RpcError>() : json.map((value) => new RpcError.fromJson(value)).toList();
  }

  static Map<String, RpcError> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, RpcError>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new RpcError.fromJson(value));
    }
    return map;
  }
}

