import 'package:businesslibrary/data/chat_message.dart';

class ChatResponse {
  String documentPath;
  String responderName;
  String responseMessage, fcmToken;
  ChatMessage chatMessage;
  String dateTime;

  ChatResponse({
    this.documentPath,
    this.responderName,
    this.responseMessage,
    this.dateTime,
    this.fcmToken,
    this.chatMessage,
  });

  static const String SUPPLIER = 'Supplier',
      CUSTOMER = 'Customer',
      STAFF = 'Staff',
      INVESTOR = 'Investor';
  ChatResponse.fromJson(Map data) {
    this.documentPath = data['documentPath'];
    this.responderName = data['responderName'];
    this.responseMessage = data['responseMessage'];
    this.dateTime = data['dateTime'];
    this.fcmToken = data['fcmToken'];
    if (data['chatMessage'] != null) {
      this.chatMessage = ChatMessage.fromJson(data['chatMessage']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['documentPath'] = this.documentPath;
    map['responderName'] = this.responderName;
    if (this.chatMessage != null) {
      print('ChatResponse.toJson --- path: ${this.chatMessage.path}');
      map['chatMessage'] = this.chatMessage.toJson();
    }

    map['responseMessage'] = this.responseMessage;
    map['dateTime'] = this.dateTime;
    map['fcmToken'] = this.fcmToken;
    return map;
  }
}
