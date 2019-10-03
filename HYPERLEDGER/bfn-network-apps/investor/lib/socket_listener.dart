import 'package:web_socket_channel/io.dart';

class TradeUtil {
  static var channel =
      new IOWebSocketChannel.connect("ws://bfnrestv3.eu-gb.mybluemix.net");
}
