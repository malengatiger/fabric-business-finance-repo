import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static showSnackBar(
      {@required BuildContext context,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor}) {
    Flushbar(
      message: message,
      leftBarIndicatorColor: Colors.yellow,
      icon: Icon(Icons.info),
      backgroundColor: backgroundColor,
    )..show(context);
  }

  static showSnackbarWithProgressIndicator(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor}) {
    if (scaffoldKey.currentState == null) {
      return;
    }
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: new Container(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            ),
          ),
          _getText(message, textColor),
        ],
      ),
      duration: new Duration(minutes: 5),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackbarWithAction(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor,
      @required String actionLabel,
      @required SnackBarListener listener,
      @required IconData icon,
      int durationMinutes,
      @required int action}) {
    if (scaffoldKey.currentState == null) {
      print(
          'AppSnackbar.showSnackbarWithAction --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0),
            child: new Container(
              height: 40.0,
              width: 40.0,
              child: Icon(icon),
            ),
          ),
          _getText(message, textColor),
        ],
      ),
      duration:
          new Duration(minutes: durationMinutes == null ? 10 : durationMinutes),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          listener.onActionPressed(action);
        },
      ),
    ));
  }

  static Widget _getText(
    String message,
    Color textColor,
  ) {
    return Text(
      message,
      overflow: TextOverflow.clip,
      style: new TextStyle(color: textColor),
    );
  }

  static showErrorSnackbar(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required SnackBarListener listener,
      @required String actionLabel}) {
    if (scaffoldKey.currentState == null) {
      print('AppSnackbar.showErrorSnackbar --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState.removeCurrentSnackBar();
    var snackbar = new SnackBar(
      content: _getText(message, Colors.white),
      duration: new Duration(seconds: 20),
      backgroundColor: Colors.red.shade900,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          listener.onActionPressed(Error);
        },
      ),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  static const Error = 0, Action = 1;
}

abstract class SnackBarListener {
  onActionPressed(int action);
}
