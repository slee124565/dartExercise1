import 'dart:io';
import 'dart:convert';

import 'case_type_samples.dart';

void main() {
  startUDPServer();
}

// UDP
void startUDPServer() async {
  var rawDatagramSocket =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

  rawDatagramSocket.broadcastEnabled = true;
  var length = rawDatagramSocket.send(
      kPDU_OP_SEARCH_REQUEST, InternetAddress('255.255.255.255'), 11188);
  print('send data len $length');

  await for (RawSocketEvent event in rawDatagramSocket) {
    if (event == RawSocketEvent.read) {
      var datagram = rawDatagramSocket.receive();
      print('received: ${datagram.address}, ${datagram.port}');
      print(datagram.data);
      // print(utf8.decode(rawDatagramSocket
      //     .receive()
      //     .data));
      // rawDatagramSocket.send(utf8.encode('UDP Server:already received!'),
      //     InternetAddress.loopbackIPv4, 8082);
      break;
    } else {
      print('other events $event');
    }
  }
}
