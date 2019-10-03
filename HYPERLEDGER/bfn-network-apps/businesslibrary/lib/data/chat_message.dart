import 'package:businesslibrary/data/chat_response.dart';

class ChatMessage {
  String participantId;
  String name;
  String message, userId;
  String date, path, userType, org, fcmToken, responseFCMToken;
  bool hasResponse;
  List<ChatResponse> responses;

  ChatMessage({
    this.participantId,
    this.name,
    this.message,
    this.userId,
    this.path,
    this.userType,
    this.org,
    this.fcmToken,
    this.hasResponse,
    this.responses,
    this.date,
    this.responseFCMToken,
  });

  static const String SUPPLIER = 'Supplier',
      CUSTOMER = 'Customer',
      STAFF = 'Staff',
      INVESTOR = 'Investor';
  ChatMessage.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.message = data['message'];
    this.date = data['date'];
    this.userId = data['userId'];
    this.path = data['path'];
    this.userType = data['userType'];
    this.org = data['org'];
    this.fcmToken = data['fcmToken'];
    this.responseFCMToken = data['responseFCMToken'];
    this.responses = List();
    if (data['responses'] != null) {
      data['responses'].forEach((m) {
        var x = ChatResponse.fromJson(m);
        responses.add(x);
      });
    }
    this.hasResponse = false;
    if (data['hasResponse'] != null) {
      this.hasResponse = true;
    }
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'participantId': participantId,
        'name': name,
        'userId': userId,
        'message': message,
        'date': date,
        'path': path,
        'userType': userType,
        'org': org,
        'fcmToken': fcmToken,
        'responseFCMToken': responseFCMToken,
        'hasResponse': hasResponse,
        'responses': responses,
      };
}
