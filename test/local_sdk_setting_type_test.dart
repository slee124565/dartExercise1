import 'dart:io';
import 'dart:typed_data';

import 'package:dartExercise1/ccapi/constants.dart';
import 'package:dartExercise1/ccapi/local_sdk_format.dart';
import 'package:dartExercise1/ccapi/tlv_t.dart';
import 'package:dotenv/dotenv.dart';
import 'package:udp/udp.dart';

class LocalSdkUdpClient {
  LocalSdkUdpClient({this.gw_ip, this.gw_port=11188}){
    _gw_address = InternetAddress(gw_ip);
  }

  void bind() async {
    var endpoint = Endpoint.any();
    _udp = await UDP.bind(endpoint);
  }

  Future<int> send(LocalSdkFormat request) {
    return _udp.send(
        Uint8List.fromList(request.toBytes()),
        Endpoint.unicast(_gw_address, port: Port(gw_port)));
  }

  Future<Uint8List> receive({int timeout=2}) async {
    await _udp.listen((datagram) {
      return datagram.data;
    }, timeout: Duration(seconds: timeout));
  }

  int gw_port;
  String gw_ip;
  InternetAddress _gw_address;
  UDP _udp;
}

LocalSdkFormat create_op_get_request(
    String gw_id, String gw_account, String gw_password, int type_id) {
  return LocalSdkFormat.op_setting_get_request(
    gw_id: gw_id,
    account: gw_account,
    password: gw_password,
    ip_address: '0.0.0.0',
    port: 11188,
    settings: [TLV.from_type_value(type: type_id)],
  );
}
Future<void> main() async {
  load();
  // var count = 0;
  var gw_id = env['gw_id'] ?? '011120031';
  var gw_account = env['gw_account'] ?? 'admin';
  var gw_password = env['gw_password'] ?? 'admin';
  var gw_ip = env['gw_ip'] ?? '192.168.50.127';
  // var app_ip = env['app_ip'] ?? '0.0.0.0';
  // print('$gw_id, $gw_account, $gw_password, $gw_ip');
  // return;
  var endpoint = Endpoint.any();
  var client = await UDP.bind(endpoint);
  var setting_types = kLocalSdkSettingTypeEnum.keys.toList();
  var n = 0;
  var type_name = setting_types[n];
  var type_id = kLocalSdkSettingTypeEnum[type_name];
  var op_request = create_op_get_request(gw_id, gw_account, gw_password, type_id);
  await client.send(Uint8List.fromList(op_request.toBytes()),
      Endpoint.unicast(InternetAddress(gw_ip), port: Port(11188)));
  while (n < setting_types.length) {
    // print('$type_name, $type_id');
    await client.listen((datagram) async {
      print('$type_name, $type_id, ${datagram.data.length}');
    }).then((value) async {
      // print('type_name $type_name');
      n = setting_types.indexOf(type_name) + 1;
      if (n < setting_types.length) {
        type_name = setting_types[n];
        type_id = kLocalSdkSettingTypeEnum[type_name];
        op_request = create_op_get_request(
            gw_id, gw_account, gw_password, type_id);
        await client.send(Uint8List.fromList(op_request.toBytes()),
            Endpoint.unicast(InternetAddress(gw_ip), port: Port(11188)));
        client.close();
      }
    }).catchError((error) {
      print('error $error');
    });
  };
}
