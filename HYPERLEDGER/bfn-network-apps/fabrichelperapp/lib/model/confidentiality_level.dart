part of swagger.api;

class ConfidentialityLevel {
  /// The underlying value of this enum member.
  String value;

  ConfidentialityLevel._internal(this.value);

  /// Confidentiality level of the Chaincode.
  static ConfidentialityLevel pUBLIC_ = ConfidentialityLevel._internal("PUBLIC");
  /// Confidentiality level of the Chaincode.
  static ConfidentialityLevel cONFIDENTIAL_ = ConfidentialityLevel._internal("CONFIDENTIAL");

  ConfidentialityLevel.fromJson(dynamic data) {
    switch (data) {
          case "PUBLIC": value = data; break;
          case "CONFIDENTIAL": value = data; break;
    default: throw('Unknown enum value to decode: $data');
    }
  }

  static dynamic encode(ConfidentialityLevel data) {
    return data.value;
  }
}

