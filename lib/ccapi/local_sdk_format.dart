// import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartExercise1/ccapi/node_all_info_t.dart';
import 'package:dartExercise1/ccapi/local_room_t.dart';
import 'package:dartExercise1/ccapi/struct_base.dart';
import 'package:dartExercise1/ccapi/zwave_scene_t.dart';
import 'package:udp/udp.dart';

import 'constants.dart';
import 'sample_data.dart';
import 'tlv_t.dart';

const K_SEARCH_OP_REQUEST = 0x01;
const K_SET_ANY_SETTING_REQ_OP = 60;
const K_GET_ANY_SETTING_REQ_OP = 63;
const K_TYPE_GATEWAY_LIST_ALL = 235;
const K_TYPE_ZWAVE_SCENE_GET_ALL_INFO = 227;
const K_TYPE_SEARCH_EXT_GATEWAY_INFO = 265;

class LocalSdkFormat {

  LocalSdkFormat._();

  @Uint8()
  static int get_next_seq_no() {
    if (LocalSdkFormat._seq_no == null) {
      LocalSdkFormat._seq_no = ((DateTime.now().millisecondsSinceEpoch) % 0xFF);
    } else {
      LocalSdkFormat._seq_no = (++LocalSdkFormat._seq_no) % 0xFF;
    }
    return LocalSdkFormat._seq_no;
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

  factory LocalSdkFormat.fromBasePdu(Uint8List pdu) {
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
    _data.tlv_size = ByteData.sublistView(pdu, index, index + 4).getUint32(0);
    assert (_data.tlv_size > 0);
    index += 4;
    _data.settings = pdu.sublist(index, index+_data.tlv_size);
    _data.empty = pdu[index++];
    _data.checksum = pdu[index++];
    assert (index == pdu.length);
    return _data;
  }

  factory LocalSdkFormat.fromTypeZwaveSceneGetAllInfoResponse(Uint8List resp_pdu) {
    var op_resp = LocalSdkFormat.fromBasePdu(resp_pdu);

    // op_resp.settings = TLV.
    return op_resp;
  }

  // factory LocalSdkFormat.fromPdu(Uint8List pdu) {
  //   var _data = LocalSdkFormat._();
  //   var index = 0;
  //   _data.reserved = pdu[index++];
  //   _data.len = pdu[index++];
  //   _data.seq_no = pdu[index++];
  //   _data.opcode = pdu[index++];
  //   _data.version = pdu[index++];
  //   _data.magic_id = pdu[index++];
  //   _data._gw_id = pdu.sublist(index, index + 3);
  //   index += 3;
  //   _data.app_id = pdu.sublist(index, index + 4);
  //   index += 4;
  //   _data._admin = pdu.sublist(index, index + 20);
  //   index += 20;
  //   _data._password = pdu.sublist(index, index + 20);
  //   index += 20;
  //   _data.app_ip = pdu.sublist(index, index + 4);
  //   index += 4;
  //   _data._app_port = pdu.sublist(index, index + 2);
  //   index += 2;
  //   _data.reserved_for_gw = pdu.sublist(index, index + 4);
  //   index += 4;
  //   _data.fail_code = pdu[index++];
  //   // _data.tlv_size = pdu.sublist(index, index + 2).buffer.asUint16List()[0];
  //   _data.tlv_size = ByteData.sublistView(pdu, index, index + 4).getUint32(0);
  //   print(
  //       'data ${pdu.sublist(index, index + 4)} as tlv_szie ${_data.tlv_size}');
  //   index += 4;
  //   // _data.settings = pdu.sublist(index, index + 4);
  //   // print('debug index $index remain data ${pdu.sublist(index)}');
  //   if (_data.tlv_size > 0) {
  //     _data.settings = TLV.from_settings(pdu.sublist(index));
  //     index += _data.tlv_size;
  //     // _data.settings.forEach((setting) {
  //     //   index += setting.toBytes().length;
  //     // });
  //   } else {
  //     _data.settings = [];
  //     print('warning tlv_size 0');
  //   }
  //   // print('[empty] field index $index remain data ${pdu.sublist(index)}');
  //   // _data.settings = pdu.sublist(index, index + 4);
  //   _data.empty = pdu[index++];
  //   _data.checksum = pdu[index++];
  //   if (index < pdu.length) {
  //     print('pdu not parsing data bytes ${pdu.sublist(index)}');
  //     print('pdu len ${pdu.length}. last index: $index');
  //   } else {
  //     print('pdu parsing matched spec');
  //   }
  //   return _data;
  // }

  static Uint8List gw_id_encode(String gw_id_str) {
    // todo: gw_id_encode not implement
    return Uint8List.fromList([10, 119, 30]);
  }

  static String gw_id_decode(Uint8List gw_id_codes) {
    //  todo: gw_id_decode not implement
    return '011120031';
  }

  static LocalSdkFormat _op_setting_common_request(
      {String gw_id,
      String account,
      String password,
      String ip_address,
      int port,
      int op_code,
      List<TLV> settings}) {
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    var op_cmd = LocalSdkFormat._();
    op_cmd.reserved = 0x00;
    op_cmd.len = 0x00;
    op_cmd.seq_no = LocalSdkFormat.get_next_seq_no();
    op_cmd.opcode = op_code;
    op_cmd.version = 0x01;
    op_cmd.magic_id = 0x88;
    op_cmd._gw_id = LocalSdkFormat.gw_id_encode(gw_id);
    op_cmd.app_id = Uint8List.fromList([0, 0, 0, 1]);
    var _admin = account.codeUnits;
    op_cmd._admin = Uint8List(20)..setRange(0, _admin.length, _admin);
    var _password = password.codeUnits;
    op_cmd._password = Uint8List(20)..setRange(0, _password.length, _password);
    op_cmd.app_ip = InternetAddress(ip_address).rawAddress;
    op_cmd._app_port = _port.buffer.asUint8List();
    op_cmd.reserved_for_gw = Uint8List(4);
    op_cmd.fail_code = 0x00;
    op_cmd.tlv_settings = settings;
    op_cmd.empty = 0x00;
    op_cmd.checksum = 0x00;
    return op_cmd;
  }

  static LocalSdkFormat op_setting_get_request(
      {String gw_id,
      String account,
      String password,
      String ip_address,
      int port,
      List<TLV> settings}) {
    return LocalSdkFormat._op_setting_common_request(
        gw_id: gw_id,
        account: account,
        password: password,
        ip_address: ip_address,
        port: port,
        op_code: K_GET_ANY_SETTING_REQ_OP,
        settings: settings);
  }

  static LocalSdkFormat op_setting_set_request(
      {String gw_id,
      String account,
      String password,
      String ip_address,
      int port,
      List<TLV> settings}) {
    return LocalSdkFormat._op_setting_common_request(
        gw_id: gw_id,
        account: account,
        password: password,
        ip_address: ip_address,
        port: port,
        op_code: K_SET_ANY_SETTING_REQ_OP,
        settings: settings);
  }

  static LocalSdkFormat gw_list_all_request(InternetAddress address, int port) {
    var tlv_type = K_TYPE_ZWAVE_SCENE_GET_ALL_INFO;
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    var op_cmd = LocalSdkFormat._();
    op_cmd.reserved = 0x00;
    op_cmd.len = 0x00;
    op_cmd.seq_no = LocalSdkFormat.get_next_seq_no();
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
    // op_cmd.app_ip = Uint8List.fromList([0,0,0,0]);
    // op_cmd._app_port = Uint8List.fromList([0,0]);
    op_cmd.reserved_for_gw = Uint8List(4);
    op_cmd.fail_code = 0x00;
    // var _unit = ByteData(2)
    //   ..setInt16(0, K_TYPE_GATEWAY_LIST_ALL)
    //   ..buffer.asUint8List();
    // op_cmd.tlv_size = 0x04;
    // op_cmd.settings = Uint8List.fromList([0, 235, 0, 0]);
    // var _settings = TLV.from_type_value(type: K_TYPE_ZWAVE_SCENE_GET_ALL_INFO);
    op_cmd.tlv_settings = [TLV.from_type_value(type: tlv_type)];
    // op_cmd.settings = Uint8List.fromList(
    //     [0, K_TYPE_ZWAVE_SCENE_GET_ALL_INFO, 0, 0, 0, 0, 0, 0]);
    // op_cmd.settings = Uint8List.fromList([0x01, 0x09, 0, 0, 0 ,0 ,0 ,0]);
    // op_cmd.settings = Uint8List.fromList([0x01, 0x09, 0, 0]);
    op_cmd.empty = 0x00;
    op_cmd.checksum = 0x00;
    return op_cmd;
  }

  static LocalSdkFormat op_search_request(InternetAddress address, int port) {
    var _port = ByteData(2)..setInt16(0, port, Endian.big);
    var op_cmd = LocalSdkFormat._();
    op_cmd.reserved = 0x00;
    op_cmd.len = 0xff;
    op_cmd.seq_no = LocalSdkFormat.get_next_seq_no();
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
    op_cmd.tlv_settings = [
      TLV.from_type_value(type: 0, value: Uint8List.fromList([0, 0, 0, 0]))
    ];
    op_cmd.empty = 0x00;
    op_cmd.checksum = 0x00;
    return op_cmd;
  }

  Uint8List toBytes() {
    var data = BytesBuilder();
    data.add([reserved, len, seq_no, opcode, version, magic_id]);
    data.add(_gw_id);
    data.add(app_id);
    data.add(_admin);
    data.add(_password);
    data.add(app_ip);
    data.add(_app_port);
    data.add(reserved_for_gw);
    data.add([fail_code]);
    // var tlv_size = ByteData(2)
    //   ..setInt16(0, settings.length);
    var _tlv_size = 0;
    tlv_settings.forEach((tlv) {
      _tlv_size += tlv.toBytes().length;
    });
    // data.add([0x00, 0x00]);
    var tlv_size = ByteData(4)..setInt32(0, _tlv_size);
    data.add(tlv_size.buffer.asUint8List());
    tlv_settings.forEach((element) {
      data.add(element.toBytes());
    });
    // data.add(settings);
    data.add([empty, checksum]);
    return data.toBytes();
  }

  @override
  String toString() {
    return '${toJson()}';
  }

  Map<String, dynamic> toJson() {
    var data = {
      'reserved': reserved,
      'len': len,
      'seq_no': seq_no,
      'opcode': opcode,
      'version': version,
      'magic_id': magic_id,
      'gw_id': gw_id,
      'app_id': app_id,
      'admin': admin,
      'password': password,
      'app_ip': app_ip,
      'app_port': app_port,
      'reserved_for_gw': reserved_for_gw,
      'fail_code': fail_code,
      'tlv_size': tlv_size,
      'settings': settings,
      'empty': empty,
      'checksum': checksum
    };
    return data;
  }

  @Uint8()
  static int _seq_no;

  @Uint8()
  int reserved = 0x00;

  @Uint8()
  int len = 0x00;

  @Uint8()
  int seq_no;

  @Uint8()
  int opcode;

  @Uint8()
  int version = 1;

  @Uint8()
  int magic_id = 0x88;

  Uint8List _gw_id;

  Uint8List app_id;

  Uint8List _admin;

  Uint8List _password;

  Uint8List app_ip;

  Uint8List _app_port;

  int get app_port {
    return ByteData.sublistView(_app_port).getUint16(0);
  }

  Uint8List reserved_for_gw;

  @Uint8()
  int fail_code;

  @Uint32()
  int tlv_size;

  List<TLV> tlv_settings;
  Uint8List settings;

  @Uint8()
  int empty;

  @Uint8()
  int checksum;
}


class _ResponseSettingsMultiBase {
  List toStructSettings(
      Uint8List resp_settings_pdu, TLVStructBase struct) {
    var settings = [];
    var n = 0;
    while ((n + 4) < resp_settings_pdu.length) {
      var _len = ByteData.sublistView(resp_settings_pdu, n + 2, n + 4).getUint16(0);
      var _type = ByteData.sublistView(resp_settings_pdu, n, n + 2).getUint16(0);
      var _seq_no = ByteData.sublistView(resp_settings_pdu, n + 4, n + 8).getUint32(0);
      assert (_type == struct.typeId);
      assert (_seq_no >= 0);
      settings.add(struct.fromUint8List(resp_settings_pdu.sublist(n + 8, n + 4 + _len)));
      n += (4 + _len);
    }
    return settings;
  }
}

class ZwaveSceneGetAllInfoResponseSettings extends _ResponseSettingsMultiBase {
  ZwaveSceneGetAllInfoResponseSettings._();

  factory ZwaveSceneGetAllInfoResponseSettings.fromSdkResponseSettings(
      Uint8List pdu) {
    var obj = ZwaveSceneGetAllInfoResponseSettings._();
    var n = 0;
    while ((n + 4) < pdu.length) {
      var _len = ByteData.sublistView(pdu, n + 2, n + 4).getUint16(0);
      var _type = ByteData.sublistView(pdu, n, n + 2).getUint16(0);
      var _seq_no = ByteData.sublistView(pdu, n + 4, n + 8).getUint32(0);
      // print('tlv type $_type from ${pdu.sublist(n, n + 2)}');
      // print('tlv len $_len from ${pdu.sublist(n + 2, n + 4)}');
      // print('tlv seq_no $_seq_no from ${pdu.sublist(n + 4, n + 8)}');
      // print('tlv value ${pdu.sublist(n + 8, n + 4 + _len)}');
      // print('tlv pdu ${pdu.sublist(n + 4, n + 4 + _len)}');
      assert (_type == kTYPE_ZWAVE_SCENE_GET_ALL_INFO);
      assert (_len > 0);
      assert (_seq_no >= 0);
      var tlv_scene = ZWaveScene.fromPdu(pdu.sublist(n + 8, n + 4 + _len));
      // var zw_scene = ZWaveScene.fromPdu(pdu.sublist(n + 4, n + 4 + _len));
      // print('scene id ${tlv_scene.scene_id} '
      //     'name ${Utf8Decoder().convert(tlv_scene.name)}');
      obj.scenes.add(tlv_scene);
      n += (4 + _len);
      // print('tlv type $_type added, n set to $n');
    }
    // print('settings parsing return at n $n, pdu len ${pdu.length}');

    return obj;
  }
  List<ZWaveScene> scenes = [];
}

class ZwaveRoomGetAllInfoResponseSettings {
  ZwaveRoomGetAllInfoResponseSettings._();

  factory ZwaveRoomGetAllInfoResponseSettings.fromSdkResponseSettings(
      Uint8List pdu
      ) {
    var obj = ZwaveRoomGetAllInfoResponseSettings._();
    var n = 0;
    while ((n + 4) < pdu.length) {
      var _len = ByteData.sublistView(pdu, n + 2, n + 4).getUint16(0);
      var _type = ByteData.sublistView(pdu, n, n + 2).getUint16(0);
      var _seq_no = ByteData.sublistView(pdu, n + 4, n + 8).getUint32(0);
      assert (_type == kTYPE_ZWAVE_ROOM_GET_ALL_INFO);
      assert (_len > 0);
      assert (_seq_no >= 0);
      var tlv_room = LocalRoom.fromPdu((pdu.sublist(n + 8, n + 4 + _len)));
      obj.rooms.add(tlv_room);
      n += (4 + _len);
    }
    return obj;
  }
  List<LocalRoom> rooms = [];
}

class ZwaveNodeAllInfoResponseSettings extends _ResponseSettingsMultiBase {
  ZwaveNodeAllInfoResponseSettings._();

  factory ZwaveNodeAllInfoResponseSettings.fromSdkResponseSettings(
      Uint8List pdu) {
    var obj = ZwaveNodeAllInfoResponseSettings._();
    var n = 0;
    while ((n + 4) < pdu.length) {
      var _len = ByteData.sublistView(pdu, n + 2, n + 4).getUint16(0);
      var _type = ByteData.sublistView(pdu, n, n + 2).getUint16(0);
      var _seq_no = ByteData.sublistView(pdu, n + 4, n + 8).getUint32(0);
      assert (_type == kTYPE_ZWAVE_NODE_ALL_INFO);
      assert (_len > 0);
      assert (_seq_no >= 0);
      var tlv_node = NodeAllInfo.fromPdu((pdu.sublist(n + 8, n + 4 + _len)));
      obj.nodes.add(tlv_node);
      n += (4 + _len);
    }
    return obj;
  }
  List<NodeAllInfo> nodes = [];
}

void main() async {
  // parse_g1_scene_get_all_info_response();
  // print('kG1SceneGetAllInfoUDPResponse.len ${kG1SceneGetAllInfoUDPResponse.length}');
  await test_g1_op_cmd();
  // await test_search_op_request();
}

void test_g1_op_cmd() async {
  print('test op_cmd ');
  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  print('local ${client.socket.address} port ${client.socket.port}');
  var op_cmd = LocalSdkFormat.gw_list_all_request(
      InternetAddress('192.168.50.127'), 11188);
  var _data = Uint8List.fromList(op_cmd.toBytes());
  // _data = Uint8List.fromList(kG1SceneGetAllInfoUDPRequest);
  print('op_cmd ${_data}, len ${_data.length}');
  print(
      'sample ${kG1SceneGetAllInfoUDPRequest} len ${kG1SceneGetAllInfoUDPRequest.length}');
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
      // var resp = LocalSdkFormat.fromPdu(datagram.data);
      // print('reserved 0x${resp.reserved.toRadixString(16)}');
      // print('len 0x${resp.len.toRadixString(16)}');
      // print('opcode 0x${resp.opcode.toRadixString(16)}');
      // print('version 0x${resp.version.toRadixString(16)}');
      // print('magic_id 0x${resp.magic_id.toRadixString(16)}');
      // print('gw_id ${resp.gw_id}');
      // print('app_id ${resp.app_id}');
      // print('admin ${resp.admin}');
      // print('password ${resp.password}');
      // print('app_ip ${resp.app_ip}');
      // print('app_port ${resp.app_port}');
      // print('reserved_for_gw ${resp.reserved_for_gw}');
      // print('fail_code ${resp.fail_code}');
      // print('tlv_size ${resp.tlv_size}');
      // print('settings:');
      // resp.settings.forEach((setting) {
      //   print('${setting.toBytes()}');
      // });
      // print('empty ${resp.empty}');
      // print('checksum ${resp.checksum}');
    }, timeout: Duration(seconds: 5));
  }
}

void test_search_op_request() async {
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

  var search_cmd = LocalSdkFormat.op_search_request(
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
      var resp = LocalSdkFormat.fromBasePdu(datagram.data);
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
      resp.tlv_settings.forEach((setting) {
        print('${setting.toBytes()}');
      });
      print('empty ${resp.empty}');
      print('checksum ${resp.checksum}');
    }, timeout: Duration(seconds: 10));
  }
  print('listen isTimeout $isTimeout');
  if (!client.closed) client.close();
}

void parse_g1_scene_get_all_info_response() {
  var test_pdu = kG1SceneGetAllInfoUDPResponse;
  print('test_pdu len ${test_pdu.length}');
  var resp = LocalSdkFormat.fromBasePdu(Uint8List.fromList(test_pdu));
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
  resp.tlv_settings.forEach((setting) {
    print('${setting.toBytes()},');
  });
  print('empty ${resp.empty}');
  print('checksum ${resp.checksum}');
}

//[0, 255, 1, 2, 1, 119, 10, 119, 30, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 208, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 55, 54, 56, 0, 1, 83, 77, 84, 80, 80, 79]
