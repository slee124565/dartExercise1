import 'dart:io';

void main() {
  RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 44444).then((
      RawDatagramSocket socket) {
    print('ready to receive');
    print('address ${socket.address} port ${socket.port}');
    socket.listen((RawSocketEvent event) {
      var datagram = socket.receive();
      print('datagram ${datagram}');
      if (datagram == null) return null;
      print('received datagram ${String.fromCharCodes(datagram.data)}');
    });
  });
}