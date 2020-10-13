import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:udp/udp.dart';

const K_SEARCH_OP_REQUEST = 0x01;
const K_GET_ANY_SETTING_REQ_OP = 63;
const K_TYPE_GATEWAY_LIST_ALL = 235;

class TLV {
  // TLV._();

  TLV({int type, Uint8List value}) {
    // var _port = ByteData(2)..setInt16(0, port, Endian.big);
    // search_op_cmd._app_port = _port.buffer.asUint8List();

    var _unit = ByteData(2)..setInt16(0, type);
    this.type = _unit.buffer.asUint8List();
    if (value == null) {
      this.value = Uint8List(4);
      _unit = ByteData(2)..setInt16(0, value.length);
      len = _unit.buffer.asUint8List();
    } else {
      this.value = value;
      _unit = ByteData(2)..setInt16(0, value.length);
      len = _unit.buffer.asUint8List();
    }
  }

  var type = Uint8List(2);
  var len = Uint8List(2);
  Uint8List value;

  Uint8List toBytes() {
    var data = BytesBuilder();
    data..add(type)..add(len)..add(value);
    return data.toBytes();
  }
}

class LocalSdkFormat {
  // LocalSdkFormat({this.opcode});

  @Uint8()
  int reserved = 0x00;

  @Uint8()
  int len = 0x00;

  @Uint8()
  static int _seq_no = 0x00;

  @Uint8()
  int seq_no;

  @Uint8()
  int opcode;

  @Uint8()
  int version = 1;

  @Uint8()
  int magic_id = 0x88;

  // Pointer<Uint8> gw_id;
  var _gw_id = Uint8List(3);

  // Pointer<Uint8> app_id;
  var app_id = Uint8List(4);

  // Pointer<Uint8> admin;
  var _admin = Uint8List(20);

  // Pointer<Uint8> password;
  var _password = Uint8List(20);

  // Pointer<Uint8> app_ip;
  var app_ip = Uint8List(4);

  // Pointer<Uint8> app_port;
  var _app_port = Uint8List(2);

  int get app_port {
    // print('$_app_port ${_app_port[0].toRadixString(16)}');
    // print('${_app_port[0].toRadixString(16)}, ${_app_port[1].toRadixString(16)}');
    // print('${ByteData.sublistView(_app_port).getUint16(0).toRadixString(16)}');
    // var _value = BytesBuilder().add(_app_port);
    return ByteData.sublistView(_app_port).getUint16(0);
    // return Uint16List.fromList(_app_port).buffer.asUint16List()[0];
  }

  // Pointer<Uint8> reserved_for_gw;
  var reserved_for_gw = Uint8List(4);

  @Uint8()
  int fail_code = 0x88;

  @Uint32()
  int tlv_size;

  // Pointer<Uint8> settings;
  var settings = Uint8List(4);

  @Uint8()
  int empty;

  @Uint8()
  int checksum;

  LocalSdkFormat._();

  void set_seq_no() {
    seq_no = ++_seq_no;
  }

  String get gw_id {
    var _value = StringBuffer();
    _gw_id.forEach((element) {
      var _part = '000' + (element + 1).toString();
      _value.write(_part.substring(_part.length - 3));
    });
    return _value.toString();
  }

  String get admin {
    return String.fromCharCodes(_admin);
  }

  String get password {
    return String.fromCharCodes(_password);
  }

  factory LocalSdkFormat.fromPdu(Uint8List pdu) {
    var _data = LocalSdkFormat._();
    var index = 0;
    _data.reserved = pdu[index++];
    _data.len = pdu[index++];
    _data.seq_no = pdu[index++];
    _data.opcode = pdu[index++];
    _data.version = pdu[index++];
    _data.magic_id = pdu[index++];
    _data._gw_id = pdu.sublist(index, index + 3);
    index += 3;
    _data.app_id = pdu.sublist(index, index + 4);
    index += 4;
    _data._admin = pdu.sublist(index, index + 20);
    index += 20;
    _data._password = pdu.sublist(index, index + 20);
    index += 20;
    _data.app_ip = pdu.sublist(index, index + 4);
    index += 4;
    _data._app_port = pdu.sublist(index, index + 2);
    index += 2;
    _data.reserved_for_gw = pdu.sublist(index, index + 4);
    index += 4;
    _data.fail_code = pdu[index++];
    _data.tlv_size = pdu.sublist(index, index + 2).buffer.asUint16List()[0];
    index += 2;
    _data.settings = pdu.sublist(index, index + 4);
    _data.empty = pdu[index++];
    _data.checksum = pdu[index++];
    print('pdu len ${pdu.length} index: $index');
    if (index < pdu.length) {
      print('remaining data bytes ${pdu.sublist(index)}');
    }
    return _data;
  }

  static LocalSdkFormat gw_list_all_request(InternetAddress address, int port) {
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    LocalSdkFormat._seq_no++;
    var search_op_cmd = LocalSdkFormat._();
    search_op_cmd.reserved = 0x00;
    search_op_cmd.len = 0x00;
    search_op_cmd.opcode = K_GET_ANY_SETTING_REQ_OP;
    search_op_cmd.version = 0x01;
    search_op_cmd.magic_id = 0x88;
    search_op_cmd._gw_id = Uint8List.fromList([10, 119, 30]);
    search_op_cmd.app_id = Uint8List.fromList([0, 0, 0, 1]);
    var _admin = 'admin'.codeUnits;
    search_op_cmd._admin = Uint8List(20)
        ..setRange(0, _admin.length, _admin);
    var _passowrd = 'password'.codeUnits;
    search_op_cmd._password = Uint8List(20)
        ..setRange(0, _passowrd.length, _passowrd);
    search_op_cmd.app_ip = address.rawAddress;
    search_op_cmd._app_port = _port.buffer.asUint8List();
    search_op_cmd.reserved_for_gw = Uint8List(4);
    search_op_cmd.fail_code = 0x00;
    search_op_cmd.tlv_size = 0x00;
    search_op_cmd.settings = Uint8List(4);
    search_op_cmd.empty = 0x00;
    search_op_cmd.checksum = 0x00;
    return search_op_cmd;
  }

  static LocalSdkFormat search_op_request(InternetAddress address, int port) {
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    LocalSdkFormat._seq_no++;
    var search_op_cmd = LocalSdkFormat._();
    search_op_cmd.reserved = 0x00;
    search_op_cmd.len = 0xff;
    search_op_cmd.opcode = K_SEARCH_OP_REQUEST;
    search_op_cmd.version = 0x01;
    search_op_cmd.magic_id = 0x88;
    search_op_cmd._gw_id = Uint8List(3);
    search_op_cmd.app_id = Uint8List.fromList([0, 0, 0, 1]);
    search_op_cmd._admin = Uint8List(20);
    search_op_cmd._password = Uint8List(20);
    search_op_cmd.app_ip = address.rawAddress;
    search_op_cmd._app_port = _port.buffer.asUint8List();
    search_op_cmd.reserved_for_gw = Uint8List(4);
    search_op_cmd.fail_code = 0x00;
    search_op_cmd.tlv_size = 0x00;
    search_op_cmd.settings = Uint8List(4);
    search_op_cmd.empty = 0x00;
    search_op_cmd.checksum = 0x00;
    return search_op_cmd;
  }

  Uint8List toBytes() {
    var data = BytesBuilder();
    data.add(
        [reserved, len, LocalSdkFormat._seq_no, opcode, version, magic_id]);
    data.add(_gw_id);
    data.add(app_id);
    data.add(_admin);
    data.add(_password);
    data.add(app_ip);
    data.add(_app_port);
    data.add(reserved_for_gw);
    data.add([fail_code]);
    data.add([0x00, 0x00]);
    data.add(settings);
    data.add([empty, checksum]);
    return data.toBytes();
  }
}

void main() async {
  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  print('local ${client.socket.address} port ${client.socket.port}');
  // print('${client.socket.address}');
  // print('${client.socket.address.rawAddress}, '
  //     '${client.socket.port.toRadixString(16)}');
  // var app_port = Uint8List(4)
  //   ..buffer.asInt16List()[0] = client.socket.port;
  // print('${app_port}');
  // var app_port = ByteData(4)..setInt32(0, client.socket.port);
  // var x = ByteData(2)..setInt16(0, client.socket.port, Endian.big);
  // print('${x.buffer.asUint8List()}');

  var search_cmd = LocalSdkFormat.search_op_request(
      client.socket.address, client.socket.port);
  print('search_op_cmd data: ${search_cmd.toBytes()}');
  var len = await client.send(
      search_cmd.toBytes(), Endpoint.broadcast(port: Port(11188)));
  print('data sent, len $len');
  var isTimeout = false;
  while (!isTimeout) {
    isTimeout = await client.listen((datagram) async {
      print('remote ip ${datagram.address}, port ${datagram.port}');
      var str = '';
      datagram.data.forEach((element) {
        str += '0x${element.toRadixString(16)}, ';
      });
      print('remote hex data: $str');
      print('remote data ${datagram.data}');
      var resp = LocalSdkFormat.fromPdu(datagram.data);
      print('reserved 0x${resp.reserved.toRadixString(16)}');
      print('len 0x${resp.len.toRadixString(16)}');
      print('opcode 0x${resp.opcode.toRadixString(16)}');
      print('version 0x${resp.version.toRadixString(16)}');
      print('magic_id 0x${resp.magic_id.toRadixString(16)}');
      print('gw_id ${resp.gw_id}');
      print('app_id ${resp.app_id}');
      print('admin ${resp.admin}');
      print('password ${resp.password}');
      print('app_ip ${resp.app_ip}');
      print('app_port ${resp.app_port}');
      print('reserved_for_gw ${resp.reserved_for_gw}');
      print('fail_code ${resp.fail_code}');
      print('tlv_size ${resp.tlv_size}');
      print('settings ${resp.settings}');
      print('empty ${resp.empty}');
      print('checksum ${resp.checksum}');
    }, timeout: Duration(seconds: 10));
  }
  print('listen isTimeout $isTimeout');
  if (!client.closed) client.close();
}

//[0, 255, 1, 2, 1, 119, 10, 119, 30, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 208, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 55, 54, 56, 0, 1, 83, 77, 84, 80, 80, 79]
