import 'dart:io';
import 'dart:typed_data';

// import 'package:dartExercise1/ccapi/constants.dart';
import 'package:dartExercise1/ccapi/local_sdk_format.dart';

// import 'package:dartExercise1/ccapi/samples.dart';
import 'package:dartExercise1/ccapi/tlv_t.dart';
import 'package:udp/udp.dart';

void main() async {
  var tlv = TLV.zwave_scene_do_action(scene_id: 2);
  // var tlv = TLV.zwave_send_data(
  //     node_id: 9, cmd_len: 3, cmd_cls_id: 98, cmd_id: 1, cmd_param: [0xff]);
  var op_request = LocalSdkFormat.op_setting_set_request(
    gw_id: '011120031',
    account: 'admin',
    password: 'admin',
    ip_address: '192.168.50.230',
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
      Endpoint.unicast(InternetAddress('192.168.50.230'), port: Port(11188)));
  print('cmd bytes: ${op_cmd.toBytes()}');
  print('data sent, len $len');
  // op_cmd.seq_no++;
  // len = await client.send(_data,
  //     Endpoint.unicast(InternetAddress('192.168.50.127'), port: Port(11188)));
  // print('cmd bytes: ${op_cmd.toBytes()}');
  // print('data sent, len $len');
  var isTimeout = false;
  while (!isTimeout) {
    isTimeout = await client.listen((datagram) async {
      print('remote ip ${datagram.address}, port ${datagram.port}');
      // var str = '';
      // datagram.data.forEach((element) {
      //   str += '0x${element.toRadixString(16)}, ';
      // });
      // print('remote hex data: $str');
      print('remote data ${datagram.data}');
      var resp = LocalSdkFormat.fromBasePdu(datagram.data);
      print('fail_code ${resp.fail_code}');
    }, timeout: Duration(seconds: 3));
  }
}
