

import 'dart:io';
import 'dart:typed_data';

import 'local_sdk_format.dart';


void main() {
  var op_cmd = LocalSdkFormat.gw_list_all_request(
      InternetAddress.anyIPv4, 63557);
  print('${op_cmd.toBytes()}');
}