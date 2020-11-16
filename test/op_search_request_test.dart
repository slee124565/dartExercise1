
import 'dart:io';
import 'dart:typed_data';

import 'package:dartExercise1/ccapi/local_sdk_format.dart';
import 'package:udp/udp.dart';

void main() async {
  var op_cmd = LocalSdkFormat.op_search_request(
      InternetAddress.fromRawAddress(Uint8List.fromList([0,0,0,0])), 0);
  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  var len = await client.send(
      op_cmd.toBytes(), Endpoint.broadcast(port: Port(11188)));
  print('op_search data ${op_cmd.toBytes()}');
  print('udp data sent len $len');
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

/* showroom g1 op_search request and response pdu
[0 reserved, 255 len, 111 seq_no, 1 op_code, 1 version, 136 magic_id,
0, 0, 0 gw_id,
0, 0, 0, 1 app_id,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 admin,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 password,
0, 0, 0, 0 app_ip,
0, 0 app_port,
0, 0, 0, 0 reserved_for_gw,
0 fail_code,
0, 0, 0, 8 tlv_size,
0, 0, 0, 4, 0, 0, 0, 0 settings,
0 empty, 0 checksum]

[0 reserved, 255 len, 171 seq_no, 2 op_code, 1 version, 119 magic_id,
10, 119, 30 gw_id,
0, 0, 0, 1 app_id,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 admin,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 password,
0, 0, 0, 0 app_ip,
0, 0 app_port,
0, 0, 0, 0 reserved_for_gw,
0 fail_code,
0, 0, 0, 8 tlv_size,
0, 0, 0, 4, 0, 0, 0, 0 settings,
0, 0, 0, 0 gmt_time,
0, 0, 0, 0, 0, 218, 0, 4, 0, 0 digest2,
0 empty, 0 checksum]
* */