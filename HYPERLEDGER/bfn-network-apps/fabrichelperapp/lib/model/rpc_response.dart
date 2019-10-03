part of swagger.api;

class RpcResponse {
  /* A string confirming successful request execution. */
  String status = null;
  
/* Additional information about the response or values returned. */
  String message = null;
  
  RpcResponse();

  @override
  String toString() {
    return 'RpcResponse[status=$status, message=$message, ]';
  }

  RpcResponse.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    status =
        json['status']
    ;
    message =
        json['message']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message
     };
  }

  static List<RpcResponse> listFromJson(List<dynamic> json) {
    return json == null ? new List<RpcResponse>() : json.map((value) => new RpcResponse.fromJson(value)).toList();
  }

  static Map<String, RpcResponse> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, RpcResponse>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new RpcResponse.fromJson(value));
    }
    return map;
  }
}

