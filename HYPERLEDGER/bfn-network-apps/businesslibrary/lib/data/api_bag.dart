class APIBag {
  String jsonString;
  String userName, functionName;

  APIBag({this.userName, this.functionName, this.jsonString});

  APIBag.fromJson(Map data) {
    this.userName = data['userName'];
    this.functionName = data['functionName'];
    this.jsonString = data['jsonString'];
  }

  Map<String, dynamic> toJson() {
    if (this.jsonString == null) {
      return {"userName": "$userName", "functionName": "$functionName"};
    } else {
      return {
        "userName": "$userName",
        "functionName": "$functionName",
        "jsonString": "$jsonString"
      };
    }
  }
}
