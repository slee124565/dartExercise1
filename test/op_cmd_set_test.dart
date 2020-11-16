import 'dart:io';
import 'dart:typed_data';

import 'package:dartExercise1/ccapi/local_sdk_format.dart';

// import 'package:dartExercise1/ccapi/samples.dart';
import 'package:dartExercise1/ccapi/tlv_t.dart';
import 'package:udp/udp.dart';

void main() async {
  var tlv = TLV.zwave_scene_do_action(scene_id:2);
  var op_request = LocalSdkFormat.op_setting_set_request(
    gw_id: '011120031',
    account: 'admin',
    password: 'admin',
    ip_address: '192.168.50.127',
    port: 11188,
    settings: [tlv],
  );
  print('cmd bytes len ${op_request.toBytes().length}');

  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  var op_cmd = op_request;
  var _data = Uint8List.fromList(op_cmd.toBytes());
  // _data = Uint8List.fromList(kSceneDoActionRequestUDP);
  var len = await client.send(_data,
      Endpoint.unicast(InternetAddress('192.168.50.127'), port: Port(11188)));
  print('cmd bytes: ${op_cmd.toBytes()}');
  print('data sent, len $len');
  // op_cmd.seq_no++;
  len = await client.send(_data,
      Endpoint.unicast(InternetAddress('192.168.50.127'), port: Port(11188)));
  print('cmd bytes: ${op_cmd.toBytes()}');
  print('data sent, len $len');
  var isTimeout = false;
  while (!isTimeout) {
    isTimeout = await client.listen((datagram) async {
      print('remote ip ${datagram.address}, port ${datagram.port}');
      var str = '';
      datagram.data.forEach((element) {
        str += '0x${element.toRadixString(16)}, ';
      });
      // print('remote hex data: $str');
      print('remote data ${datagram.data}');
      var resp = LocalSdkFormat.fromBasePdu(datagram.data);
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
      print('fail_code ${resp.fail_code}');
      // print('tlv_size ${resp.tlv_size}');
      // print('settings:');
      // resp.settings.forEach((setting) {
      //   print('${setting.toBytes()}');
      // });
      // print('empty ${resp.empty}');
      // print('checksum ${resp.checksum}');
    }, timeout: Duration(seconds: 3));
  }
}
