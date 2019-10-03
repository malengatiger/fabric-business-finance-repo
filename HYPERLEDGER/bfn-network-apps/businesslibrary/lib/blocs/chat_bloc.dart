import 'dart:async';
import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatBlocListener {
  onEvent(String message);
}

class ChatBloc {
  final StreamController<ChatResponse> _chatResponseController =
      StreamController<ChatResponse>.broadcast();
  final StreamController<ChatMessage> _chatMessageController =
      StreamController<ChatMessage>.broadcast();
  final Firestore fs = Firestore.instance;
  ChatBloc() {
    print('\n\nChatBloc.ChatBloc - CONSTRUCTOR - wait for chatt responses');
  }

  closeStream() {
    _chatResponseController.close();
    _chatMessageController.close();
  }

  get chatResponseStream => _chatResponseController.stream;
  get chatMessageStream => _chatMessageController.stream;

  receiveChatResponse(ChatResponse chatResponse) {
    print(
        'ChatBloc.receiveChatResponse ... calling:  _chatController.sink.add(chatResponse);');
    _chatResponseController.sink.add(chatResponse);
  }

  Future addChatMessage(ChatMessage chatMessage) async {
    print('ChatBloc.addChatMessage ..... adding chat message to Firestore');
    var result = await DataAPI3.addChatMessage(chatMessage);
    return result;
  }

  Future addChatResponse(ChatResponse chatResponse) async {
    print('ChatBloc.addChatResponse ..... adding chat response to Firestore, delete pending ...');

    var result = await DataAPI3.addChatResponse(chatResponse);
    await removePendingMessage(chatResponse.chatMessage);
    return result;
  }

  receiveChatMessage(ChatMessage chatMessage) {
    print(
        'ChatBloc.receiveChatMessage ... calling _chatMessageController.sink.add(chatMessage)');
    _chatMessageController.sink.add(chatMessage);
  }

  Future<List<ChatMessage>> getChatMessages(String userId) async {
    var chatMessages = await ListAPI.getChatMessages(userId);
    return chatMessages;
  }

  Future<List<ChatMessage>> getPendingChatMessages() async {
    List<ChatMessage> list = List();
    var qs = await fs
        .collection('chatResponsesPending')
        .where('hasResponse', isEqualTo: null)
        .orderBy('date')
        .getDocuments();
    qs.documents.forEach((doc) {
      var msg = ChatMessage.fromJson(doc.data);
      list.add(msg);
    });
    return list;
  }

  Future removePendingMessage(ChatMessage msg) async {
    await fs.document(msg.path).delete();
    print('ChatBloc.removePendingMessage ------- msg removed from pending messages ${msg.toJson()} ...');
  }
}

final chatBloc = ChatBloc();
