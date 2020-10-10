// import 'dart:io';

import 'package:udp/udp.dart';

void start_server() async {
  var server = await UDP.bind(Endpoint.any(port: Port(65000)));
  var isTimeout = false;
  while (!isTimeout) {
    isTimeout = await server.listen((datagram) async {
      var str = String.fromCharCodes(datagram.data);
      print('server receive data $str, '
          'client ${datagram.address}, ${datagram.port}');
      await server.send('server echo'.codeUnits,
          Endpoint.unicast(datagram.address, port: Port(datagram.port)));
    }, timeout: Duration(seconds: 3));
  }
  await server.close();
  print('server timeout $isTimeout closed');
}

void start_client() async {
  var client = await UDP.bind(Endpoint.any());
  var len = await client.send(
      'ping'.codeUnits, Endpoint.broadcast(port: Port(65000)));
  // await client.send('ping'.codeUnits, Endpoint.any(port: Port(65000)));
  print('client send data len $len');
  await client.listen((datagram) async {
    var str = String.fromCharCodes(datagram.data);
    print('client receive $str');
    await client.close();
    print('client closed');
  });
}

void main() async {
  start_server();
  await Future.delayed(Duration(seconds: 1));
  start_client();
  start_client();
  start_client();
}
