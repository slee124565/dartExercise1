
import 'dart:typed_data';

import 'local_sdk_format.dart';

void main() {
  var pdu = Uint8List.fromList([
    0, 255, 1, 2, 1, 119, 10, 119, 30, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 208, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 55, 54, 56, 0, 1, 83, 77, 84,
    80, 80, 79]);
  print('${pdu.length}');
  var resp = LocalSdkFormat.fromBasePdu(pdu);
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
  print('settings ${resp.tlv_settings}');
  print('empty ${resp.empty}');
  print('checksum ${resp.checksum}');
}