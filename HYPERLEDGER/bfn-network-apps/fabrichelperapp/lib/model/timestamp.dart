part of swagger.api;

class Timestamp {
  /* Represents seconds of UTC time since Unix epoch 1970-01-01T00:00:00Z. Must be from from 0001-01-01T00:00:00Z to 9999-12-31T23:59:59Z inclusive. */
  int seconds = null;
  
/* Non-negative fractions of a second at nanosecond resolution. Negative second values with fractions must still have non-negative nanos values that count forward in time. Must be from 0 to 999,999,999 inclusive. */
  int nanos = null;
  
  Timestamp();

  @override
  String toString() {
    return 'Timestamp[seconds=$seconds, nanos=$nanos, ]';
  }

  Timestamp.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    seconds =
        json['seconds']
    ;
    nanos =
        json['nanos']
    ;
  }

  Map<String, dynamic> toJson() {
    return {
      'seconds': seconds,
      'nanos': nanos
     };
  }

  static List<Timestamp> listFromJson(List<dynamic> json) {
    return json == null ? new List<Timestamp>() : json.map((value) => new Timestamp.fromJson(value)).toList();
  }

  static Map<String, Timestamp> mapFromJson(Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, Timestamp>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) => map[key] = new Timestamp.fromJson(value));
    }
    return map;
  }
}

