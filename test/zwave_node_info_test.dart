
// [
// 0 reserved, 0 len, 131 seq_no, 63 op_code, 1 version, 136 magic_id,
// 10, 119, 30, gw_id
// 0, 0, 0, 1 app_id,
// 97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
// 97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
// 0, 0, 0, 0,
// 43, 180,
// 0, 0, 0, 0,
// 0 fail_code,
// 0, 0, 0, 5 tlv_size, 0, 206, 0, 1, 9, 0, 0]

// 0 reserved,
// 0 len,
// 175 seq_no,
// 64 op_code,
// 1 version,
// 119 magic_id,
// 10, 119, 30 gw_id,
// 0, 0, 0, 1 app_id,
// 97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 admin,
// 97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 password,
// 192, 168, 50, 127 gw_ip,
// 43, 180 gw_port,
// 0, 0, 0, 0 reserved_for_gw,
// 0 fail_code,
// 0, 0, 25, 232 tlv_size,

import 'dart:io';
import 'dart:typed_data';

import 'package:dartExercise1/ccapi/constants.dart';
import 'package:dartExercise1/ccapi/local_sdk_format.dart';

// import 'package:dartExercise1/ccapi/samples.dart';
import 'package:dartExercise1/ccapi/tlv_t.dart';
import 'package:udp/udp.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

import 'case_type_samples.dart';

void main() async {
  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  var _data = Uint8List.fromList(kPDU_TYPE_ZWAVE_NODE_INFO_REQUUEST);
  // _data = Uint8List.fromList(kSceneDoActionRequestUDP);
  var len = await client.send(_data,
      Endpoint.unicast(InternetAddress('192.168.50.230'), port: Port(11188)));
  // len = await client.send(_data,
  //     Endpoint.unicast(InternetAddress('192.168.50.127'), port: Port(11188)));
  print('cmd bytes: ${_data}');
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
      print('response ${resp}');
    }, timeout: Duration(seconds: 3));
  }
}

/// 0x80 = 0b 1000 0000
/// request
/// [0, 206, 1, 56, 0, 0, 0, 9, 83, 0, 0, 4, 8, 6, 25, 83, 79, 78, 89, 194, 160, 84, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 3, 68, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 67, 3, 2, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 49, 5, 1, 34, 0, 240, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 128, 3, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 114, 5, 1, 60, 1, 2, 130, 144, 119, 1, 201, 197, 192, 244, 95, 233, 95, 169, 95, 0, 0, 0, 0, 0, 0, 0, 0, 9, 94, 2, 1, 7, 0, 18, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 34, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 64, 3, 0, 2, 0, 0, 116, 199, 133, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 134, 18, 3, 4, 33, 1, 5, 3, 2, 1, 20, 182, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 112, 6, 27, 2, 0, 0, 236, 30, 234, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
/// response
/// [0, 0, 131, 64, 1, 119, 10, 119, 30, 0, 0, 0, 1, 97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 180, 0, 0, 0, 0, 0, 0, 0, 1, 60,
/// 0, 206, 1, 56, 0, 0, 0, 9, 83, 0, 0, 4, 8, 6, 25,
/// 83, 79, 78, 89, 194, 160, 84, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 node_name,
/// 10 num_cmds,
/// 3, 68, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 5, 67, 3, 2, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 6, 49, 5, 1, 34, 0, 240, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 3, 128, 3, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 8, 114, 5, 1, 60, 1, 2, 130, 144, 119, 1, 201, 197, 192, 244, 95, 233, 95, 169, 95, 0, 0, 0, 0, 0, 0, 0, 0,
/// 9, 94, 2, 1, 7, 0, 18, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 4, 34, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 3, 64, 3, 0, 2, 0, 0, 116, 199, 133, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 13, 134, 18, 3, 4, 33, 1, 5, 3, 2, 1, 20, 182, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/// 6, 112, 6, 27, 2, 0, 0, 236, 30, 234, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]