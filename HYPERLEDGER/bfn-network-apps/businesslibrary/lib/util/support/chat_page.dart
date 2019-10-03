import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/chat_bloc.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final ChatResponse chatResponse;
  final Function doSomething;
  ChatPage({this.chatResponse, this.doSomething});

  @override
  State createState() => new ChatWindow();
}

class ChatWindow extends State<ChatPage> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Firestore fs = Firestore.instance;
  List<ChatMessage> chatMessages = List();
  bool _isWriting = false;
  User user;
  Customer customer;
  Supplier supplier;
  Investor investor;
  String uType, participantId, org;
  String fcmToken;
  ChatResponse _chatResponse;
  @override
  void initState() {
    super.initState();
    _getCached();
    if (widget.chatResponse != null) {
      _chatResponse = widget.chatResponse;
    }
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    fcmToken = await SharedPrefs.getFCMToken();
    assert(user != null);
    print('\n\n\nChatWindow._getCached ====== user: ${user.toJson()}');
    widget.doSomething();
    if (widget.chatResponse == null) {
      _getMessages();
    } else {
      _submitMsg(
          txt: _chatResponse.responseMessage,
          color: Colors.pink,
          addToFirestore: false,
          name: _chatResponse.responderName +
              ': ' +
              getFormattedDateShortWithTime(_chatResponse.dateTime, context));
    }

    if (user.supplier != null) {
      uType = ChatMessage.SUPPLIER;
      supplier = await SharedPrefs.getSupplier();
      participantId = supplier.participantId;
      org = supplier.name;
    }
    if (user.customer != null) {
      uType = ChatMessage.CUSTOMER;
      customer = await SharedPrefs.getCustomer();
      participantId = customer.participantId;
      org = customer.name;
    }
    if (user.investor != null) {
      uType = ChatMessage.INVESTOR;
      investor = await SharedPrefs.getInvestor();
      participantId = investor.participantId;
      org = investor.name;
    }
    print('ChatWindow._getCached ------- uType : $uType');
  }

  List<ChatResponse> chatResponses = List();
  void _getMessages() async {
    print('ChatWindow._getMessages %%%%%%%%%% start ......');
    chatMessages = await chatBloc.getChatMessages(user.userId);
    chatMessages.sort((xa, xb) => xa.date.compareTo(xb.date));
    chatMessages.forEach((m) {
      _submitMsg(
          txt: m.message,
          addToFirestore: false,
          color: Colors.indigo,
          name: user.firstName +
              ': ' +
              getFormattedDateShortWithTime(m.date, context));
    });

    var start = DateTime.now();
    print(
        'ChatWindow._getMessages ... ################## found: ${chatMessages.length} ... finding responses ....');

    _messages.clear();
    chatMessages.sort((xa, xb) => xa.date.compareTo(xb.date));
    chatMessages.forEach((m) {
      _submitMsg(
          txt: m.message,
          addToFirestore: false,
          color: Colors.indigo,
          name: user.firstName +
              ': ' +
              getFormattedDateShortWithTime(m.date, context));
      if (m.responses != null && m.responses.isNotEmpty) {
        m.responses.forEach((r) {
          _submitMsg(
              txt: r.responseMessage,
              addToFirestore: false,
              color: Colors.pink,
              name: r.responderName +
                  ': ' +
                  getFormattedDateShortWithTime(r.dateTime, context));
        });
      }
    });
    var end = DateTime.now();
    print(
        'ChatWindow._getMessages ########### getting responses took ${end.difference(start).inMilliseconds} ms');
  }

  void _addMessage(String text) async {
    assert(text != null);
    print(
        'ChatWindow._addMessage ------------------------------------> \n$text');

    assert(uType != null);
    assert(fcmToken != null);
    var cm = ChatMessage(
      date: DateTime.now().toIso8601String(),
      message: text,
      name: user.firstName,
      participantId: participantId,
      userId: user.userId,
      userType: uType,
      fcmToken: fcmToken,
      org: org,
    );
    if (_chatResponse != null) {
      prettyPrint(_chatResponse.toJson(), 'ChatResponse received from FCM');
      cm.responseFCMToken = _chatResponse.fcmToken;
    }
    prettyPrint(cm.toJson(), 'ChatMessage to send to DataAPI3 ..');
    try {
      ChatMessage resp = await chatBloc.addChatMessage(cm);
      prettyPrint(resp.toJson(), '######### message from function call:');
    } catch (e) {
      print(e);
//      AppSnackbar.showErrorSnackbar(
//          scaffoldKey: _scaffoldKey,
//          message: 'Message cannot be sent',
//          listener: this,
//          actionLabel: 'close');
    }
  }

  Widget _getColumn() {
    print(
        'ChatWindow._getColumn rebuilding ListView ...... ${_messages.length}');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Column(
          children: <Widget>[
            new Flexible(
                child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            )),
            new Divider(height: 4.0),
            new Container(
              child: _buildComposer(),
              decoration: new BoxDecoration(color: Colors.brown.shade100),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return StreamBuilder<ChatResponse>(
      stream: chatBloc.chatResponseStream,
      builder: (context, snapshot) {
        print('ChatWindow.build ......... in StreamBuilder method');
        processResponse(snapshot);
        return Scaffold(
          appBar: new AppBar(
            title: new Text("BFN Support Chat"),
            elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
          ),
          backgroundColor: Colors.brown.shade100,
          body: _getColumn(),
        );
      },
    );
  }

  void processResponse(AsyncSnapshot<ChatResponse> snapshot) {
    if (snapshot.hasError) {
      print('ChatWindow.build ----------------- snapshot.hasError');
      return;
    }
    if (snapshot.hasData) {
      print(
          'ChatWindow.build ----------------- snapshot.hasData: ${snapshot.data.toJson()}');
      if (_chatResponse != null) {
        if (_chatResponse.documentPath == snapshot.data.documentPath) {
          print('ChatWindow.build ------- IGNORE, already known');
        } else {
          addResponseToView(snapshot);
        }
      } else {
        addResponseToView(snapshot);
      }
    }
  }

  void addResponseToView(AsyncSnapshot<ChatResponse> snapshot) {
    _chatResponse = snapshot.data;
    Msg msg = Msg(
      defaultUserName: _chatResponse.responderName,
      txt: _chatResponse.responseMessage,
      color: Colors.pink,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );
    _messages.insert(0, msg);
    msg.animationController.forward();
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  style: Styles.blackMedium,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                      hintText: "Enter some text ..."),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoButton(
                          child: new Text("Submit"),
                          onPressed: _isWriting
                              ? () => _submitMsg(
                                  color: Colors.indigo,
                                  txt: _textController.text,
                                  name: user == null ? ' n/a ' : user.firstName,
                                  addToFirestore: true)
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.message),
                          onPressed: _isWriting
                              ? () => _submitMsg(
                                  color: Colors.indigo,
                                  txt: _textController.text,
                                  name: user == null ? ' n/a ' : user.firstName,
                                  addToFirestore: true)
                              : null,
                        )),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.brown)))
              : null),
    );
  }

  void _submitMsg({String txt, bool addToFirestore, Color color, String name}) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = Msg(
      defaultUserName: name == null ? 'NOT KNOWN' : name,
      txt: txt,
      color: color,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );

    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
    //
    if (addToFirestore) {
      _addMessage(txt);
    }
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }
}

class Msg extends StatelessWidget {
  Msg({this.txt, this.animationController, this.defaultUserName, this.color});
  final String txt, defaultUserName;
  final AnimationController animationController;
  final Color color;

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 18.0, left: 12),
              child: new CircleAvatar(
                  radius: 12.0,
                  backgroundColor: color == null ? Colors.indigo : color,
                  child: new Text(
                    defaultUserName[0],
                    style: Styles.whiteSmall,
                  )),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                      defaultUserName == null ? 'Anonymous' : defaultUserName,
                      style: Theme.of(ctx).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt == null ? ' n/a ' : txt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
