import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:udp/udp.dart';

const K_SEARCH_OP_REQUEST = 0x01;
const K_GET_ANY_SETTING_REQ_OP = 63;
const K_TYPE_GATEWAY_LIST_ALL = 235;
const K_TYPE_ZWAVE_SCENE_GET_ALL_INFO = 227;
const K_TYPE_SEARCH_EXT_GATEWAY_INFO = 265;

class TLV {
  TLV._({this.type, this.len, this.value});

  TLV.from_type_value({int type, Uint8List value}) {
    var _type = ByteData(2)..setInt16(0, type);
    this.type = _type.buffer.asUint8List();
    if (value == null) {
      this.value = Uint8List.fromList([0, 0, 0, 0]);
    } else {
      this.value = value;
    }
    var _len = ByteData(2)..setInt16(0, this.value.length);
    len = _len.buffer.asUint8List();
  }

  static List<TLV> from_settings(int tlv_size, Uint8List pdu) {
    var _settings = <TLV>[];
    var n = 0;
    while (n < pdu.length) {
      var _len = ByteData.sublistView(pdu, n + 2, n + 4).getUint16(0);
      if (_len > 0) {
        _settings.add(TLV._(
            type: pdu.sublist(n, n + 2),
            len: pdu.sublist(n + 2, n + 4),
            value: pdu.sublist(n + 4, n + 4 + _len)));
        n += (4 + _len);
      } else {
        if ((n + 8) > pdu.length) {
          _settings.add(TLV._(
              type: pdu.sublist(n, n + 2),
              len: pdu.sublist(n + 2, n + 4),
              value: pdu.sublist(n + 4, n + 8)));
          n += 8;
        } else {
          _settings.add(TLV._(
              type: pdu.sublist(n, n + 2),
              len: pdu.sublist(n + 2, n + 4),
              value: pdu.sublist(n + 4)));
          n = pdu.length;
        }
      }
      if (_settings.length >= tlv_size) break;
    }
    return _settings;
  }

  Uint8List type;
  Uint8List len;
  Uint8List value;

  Uint8List toBytes() {
    var data = BytesBuilder();
    data.add(type);
    data.add(len);
    data.add(value);
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
  // var settings = Uint8List(4);
  List<TLV> settings;

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
    // _data.tlv_size = pdu.sublist(index, index + 2).buffer.asUint16List()[0];
    _data.tlv_size = ByteData.sublistView(pdu, index, index+2).getUint16(0);
    print('data ${pdu.sublist(index, index + 2)} as tlv_szie ${_data.tlv_size}');
    index += 2;
    // _data.settings = pdu.sublist(index, index + 4);
    print('debug index $index remain data ${pdu.sublist(index)}');
    if (_data.tlv_size > 0) {
      _data.settings =
          TLV.from_settings(_data.tlv_size, pdu.sublist(index));
      _data.settings.forEach((setting) {
        index += setting.toBytes().length;
      });
    } else {
      _data.settings = [];
      print('warning tlv_size 0');
    }
    print('[empty] index $index remain data ${pdu.sublist(index)}');
    // _data.settings = pdu.sublist(index, index + 4);
    _data.empty = pdu[index++];
    _data.checksum = pdu[index++];
    if (index < pdu.length) {
      print('pdu not parsing data bytes ${pdu.sublist(index)}');
      print('pdu len ${pdu.length}. last index: $index');
    }
    return _data;
  }

  static LocalSdkFormat gw_list_all_request(InternetAddress address, int port) {
    // var tlv_type = K_TYPE_ZWAVE_SCENE_GET_ALL_INFO;
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    LocalSdkFormat._seq_no++;
    var op_cmd = LocalSdkFormat._();
    op_cmd.reserved = 0x00;
    op_cmd.len = 0x00;
    op_cmd.opcode = K_GET_ANY_SETTING_REQ_OP;
    op_cmd.version = 0x01;
    op_cmd.magic_id = 0x88;
    op_cmd._gw_id = Uint8List.fromList([10, 119, 30]);
    op_cmd.app_id = Uint8List.fromList([0, 0, 0, 1]);
    var _admin = 'admin'.codeUnits;
    op_cmd._admin = Uint8List(20)..setRange(0, _admin.length, _admin);
    var _password = 'admin'.codeUnits;
    op_cmd._password = Uint8List(20)..setRange(0, _password.length, _password);
    op_cmd.app_ip = address.rawAddress;
    op_cmd._app_port = _port.buffer.asUint8List();
    op_cmd.reserved_for_gw = Uint8List(4);
    op_cmd.fail_code = 0x00;
    // var _unit = ByteData(2)
    //   ..setInt16(0, K_TYPE_GATEWAY_LIST_ALL)
    //   ..buffer.asUint8List();
    // op_cmd.tlv_size = 0x04;
    // op_cmd.settings = Uint8List.fromList([0, 235, 0, 0]);
    // var _settings = TLV.from_type_value(type: K_TYPE_ZWAVE_SCENE_GET_ALL_INFO);
    op_cmd.settings = [
      TLV.from_type_value(type: K_TYPE_ZWAVE_SCENE_GET_ALL_INFO)
    ];
    // op_cmd.settings = Uint8List.fromList(
    //     [0, K_TYPE_ZWAVE_SCENE_GET_ALL_INFO, 0, 0, 0, 0, 0, 0]);
    // op_cmd.settings = Uint8List.fromList([0x01, 0x09, 0, 0, 0 ,0 ,0 ,0]);
    // op_cmd.settings = Uint8List.fromList([0x01, 0x09, 0, 0]);
    op_cmd.empty = 0x00;
    op_cmd.checksum = 0x00;
    return op_cmd;
  }

  static LocalSdkFormat search_op_request(InternetAddress address, int port) {
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    LocalSdkFormat._seq_no++;
    var op_cmd = LocalSdkFormat._();
    op_cmd.reserved = 0x00;
    op_cmd.len = 0xff;
    op_cmd.opcode = K_SEARCH_OP_REQUEST;
    op_cmd.version = 0x01;
    op_cmd.magic_id = 0x88;
    op_cmd._gw_id = Uint8List(3);
    op_cmd.app_id = Uint8List.fromList([0, 0, 0, 1]);
    op_cmd._admin = Uint8List(20);
    op_cmd._password = Uint8List(20);
    op_cmd.app_ip = address.rawAddress;
    op_cmd._app_port = _port.buffer.asUint8List();
    op_cmd.reserved_for_gw = Uint8List(4);
    op_cmd.fail_code = 0x00;
    op_cmd.tlv_size = 0x00;
    op_cmd.settings = [
      TLV.from_type_value(type: 0, value: Uint8List.fromList([0, 0, 0, 0]))
    ];
    op_cmd.empty = 0x00;
    op_cmd.checksum = 0x00;
    return op_cmd;
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
    var tlv_size = ByteData(2)..setInt16(0, settings.length);
    // data.add([0x00, 0x00]);
    data.add(tlv_size.buffer.asUint8List());
    // settings.forEach((TLV element) { })
    settings.forEach((element) {
      data.add(element.toBytes());
    });
    // data.add(settings);
    data.add([empty, checksum]);
    return data.toBytes();
  }
}

void main() async {
  print('test op_cmd ');
  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  print('local ${client.socket.address} port ${client.socket.port}');
  var op_cmd = LocalSdkFormat.gw_list_all_request(
      InternetAddress('192.168.50.127'), 11188);
  var _data = op_cmd.toBytes();
  print('op_cmd ${_data}');
  var len = await client.send(_data,
      Endpoint.unicast(InternetAddress('192.168.50.127'), port: Port(11188)));
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
      print('settings:');
      resp.settings.forEach((setting) {
        print('${setting.toBytes()}');
      });
      print('empty ${resp.empty}');
      print('checksum ${resp.checksum}');
    }, timeout: Duration(seconds: 10));
  }
}

void _main() async {
  print('= test search_op_request =');
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
      print('settings:');
      resp.settings.forEach((setting) {
        print('${setting.toBytes()}');
      });
      print('empty ${resp.empty}');
      print('checksum ${resp.checksum}');
    }, timeout: Duration(seconds: 10));
  }
  print('listen isTimeout $isTimeout');
  if (!client.closed) client.close();
}

//[0, 255, 1, 2, 1, 119, 10, 119, 30, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 208, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 55, 54, 56, 0, 1, 83, 77, 84, 80, 80, 79]
