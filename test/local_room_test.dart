

import 'dart:typed_data';

import 'package:dartExercise1/ccapi/local_sdk_format.dart';

import 'case_type_samples.dart';

void main() {
  var sdk_resp = LocalSdkFormat.fromBasePdu(
    Uint8List.fromList(kPDU_TYPE_ZWAVE_ROOM_GET_ALL_INFO_RESPONSE)
  );
  var rooms = ZwaveRoomGetAllInfoResponseSettings.fromSdkResponseSettings(
    sdk_resp.settings
  ).rooms;
  rooms.forEach((room) {
    print('${room.toJson()}');
  });

}

/*
[
0 reserved, 0 len, 59 seq_no, 64 op_code, 1 version, 119 magic_id,
10, 119, 30 gw_id, 0, 0, 0, 1 app_id,
97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
97, 100, 109, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
192, 168, 50, 127, 43, 180,
0, 0, 0, 0, 0,
0, 0, 0, 201 tlv_size,
0, 218, 0, 54, 0, 0, 0, 0, 117, 110, 97, 115, 115, 105, 103, 110, 101, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 10, 0, 0, 0, 0, 14, 22, 14, 15, 21, 23, 26, 20, 28, 29, 31, 33, 34, 35, 37,
0, 218, 0, 51, 0, 0, 0, 1, 232, 135, 165, 229, 174, 164, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 6, 6, 10, 0, 0, 0, 0, 11, 2, 5, 3, 6, 7, 9, 10, 13, 24, 25, 18,
0, 218, 0, 40, 0, 0, 0, 2, 228, 186, 140, 230, 168, 147, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 218, 0, 40, 0, 0, 0, 3, 230, 184, 172, 232, 169, 166, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
 */