import 'package:businesslibrary/blocs/chat_bloc.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatResponsePage extends StatefulWidget {
  final ChatMessage chatMessage;

  ChatResponsePage({this.chatMessage});

  @override
  State createState() => new ChatResponseWindow();
}

class ChatResponseWindow extends State<ChatResponsePage>
    with TickerProviderStateMixin
    implements SnackBarListener {
  final List<Msg> _messages = <Msg>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController _textController = new TextEditingController();
  final Firestore fs = Firestore.instance;
  List<ChatMessage> chatMessagesPending = List(), filteredMessages = List();
  bool _isWriting = false;
  String fcmToken;
  @override
  void initState() {
    super.initState();

    if (widget.chatMessage == null) {
      _getMessages();
    } else {
      selectedMessage = widget.chatMessage;
      addChatMessageToView();
    }
  }

  void _getMessages() async {
    print('ChatResponseWindow._getMessages Pending %%%%%%%%%% start ......');
    chatMessagesPending = await chatBloc.getPendingChatMessages();
    print(
        'ChatResponseWindow._getMessages --- pending messages: ${chatMessagesPending.length}');
    setState(() {});
  }

  ChatMessage selectedMessage;
  List<DropdownMenuItem<ChatMessage>> dropdownMenuItems = List();
  Map<String, ChatMessage> map = Map();
  void _buildDropDownItems() {
    if (chatMessagesPending == null) return;
    print(
        'ChatResponseWindow._buildDropDownItems - chatMessagesPending: ${chatMessagesPending.length}');

    chatMessagesPending.forEach((m) {
      var x = DropdownMenuItem<ChatMessage>(
        value: m,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.assignment,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${m.name}, ${getFormattedDateShortWithTime(m.date, context)}',
                style: Styles.blackBoldSmall,
              ),
            )
          ],
        ),
      );

      dropdownMenuItems.add(x);
    });
    setState(() {});
  }

  void _addChatResponse(String text) async {
    assert(text != null);
    print('ChatResponseWindow._addMessage --> $text');
    assert(selectedMessage != null);
    var cm = ChatResponse(
      dateTime: getUTCDate(),
      responseMessage: text,
      chatMessage: selectedMessage,
      responderName: 'BFN Support',
      fcmToken: fcmToken,
    );
    prettyPrint(cm.toJson(), '.... about to write this chatResponse:');
    try {
      ChatResponse resp = await chatBloc.addChatResponse(cm);
      prettyPrint(resp.toJson(), '###### function call returned ChatResponse:');
    } catch (e) {
      print(e);
//      AppSnackbar.showErrorSnackbar(
//          scaffoldKey: _scaffoldKey,
//          message: 'Chat response failed',
//          listener: this,
//          actionLabel: 'close');
    }
    //setState(() {});
  }

  Widget _getColumn() {
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

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DropdownButton<ChatMessage>(
              onChanged: _onMessageSelected,
              items: dropdownMenuItems,
              elevation: 4,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select Message',
                  style: Styles.whiteBoldMedium,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  selectedMessage == null
                      ? ''
                      : '${selectedMessage.name} ${getFormattedDateShortWithTime(selectedMessage.date, context)}',
                  style: Styles.blackBoldMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    print(
        'ChatResponseWindow.build #################### rebuild widget + _configureFCM');
    _buildDropDownItems();
    return StreamBuilder<ChatMessage>(
      stream: chatBloc.chatMessageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              '\n\nChatResponseWindow.build ---------- snapshot.hasError ---------');
        }
        processChatMessage(snapshot);
        return Scaffold(
          appBar: new AppBar(
            title: new Text("Support Chat"),
            elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
            bottom: _getBottom(),
            actions: <Widget>[
              IconButton(
                onPressed: _getRegularUsers,
                icon: Icon(
                  Icons.people,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.brown.shade100,
          body: _getColumn(),
        );
      },
    );
  }

  void processChatMessage(AsyncSnapshot<ChatMessage> snapshot) {
    if (snapshot.hasData) {
      if (selectedMessage != null) {
        if (selectedMessage.path == snapshot.data.path) {
          //ignore
        } else {
          selectedMessage = snapshot.data;
          addChatMessageToView();
        }
      } else {
        selectedMessage = snapshot.data;
        addChatMessageToView();
      }
    }
  }

  void addChatMessageToView() {
    Msg msg = Msg(
      defaultUserName: selectedMessage.name,
      txt: selectedMessage.message,
      color: Colors.indigo,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );
    _messages.insert(0, msg);
    msg.animationController.forward();
  }

  _getRegularUsers() {
    print('ChatResponseWindow._getRegularUsers .................');
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
                  style: Styles.blackBoldSmall,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                      hintText: "Enter some text to send a message"),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoButton(
                          child: new Text("Submit"),
                          onPressed: _isWriting
                              ? () => _submitMsg(
                                  txt: _textController.text,
                                  addToFirestore: true,
                                  defaultUserName: 'Support Staff')
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.message),
                          onPressed: _isWriting
                              ? () => _submitMsg(
                                  txt: _textController.text,
                                  addToFirestore: true,
                                  defaultUserName: 'Support Staff')
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

  void _submitMsg(
      {String txt, bool addToFirestore, Color color, String defaultUserName}) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    if (color == null) color = Colors.pink;
    Msg msg = Msg(
      defaultUserName: defaultUserName,
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
      _addChatResponse(txt);
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

  void _onMessageSelected(ChatMessage msg) {
    prettyPrint(msg.toJson(), 'ChatResponseWindow._onMessageSelected ...');
    selectedMessage = msg;
    _messages.clear();
    _submitMsg(
        addToFirestore: false,
        txt: msg.message,
        color: Colors.indigo,
        defaultUserName: msg.name);
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
                  backgroundColor: color == null ? Colors.pink : color,
                  child: new Text(
                    defaultUserName[0] + defaultUserName[1],
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
                    child: new Text(txt == null ? '' : txt),
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
