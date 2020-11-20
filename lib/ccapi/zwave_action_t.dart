
import 'dart:ffi';
import 'dart:typed_data';

import 'cmd_status_t.dart';

class ZWaveAction {
  static int length = 4+kMAX_CMD_STATUS_SIZE+4;

  ZWaveAction.fromPdu(Uint8List pdu) {
    var n = 0;
    node_id = pdu[n++];
    room_id = pdu[n++];
    camera_action = pdu[n++];
    duration = pdu[n++];
    cmd_status = CmdStatus.fromPdu(pdu.sublist(n));
  }

  Map<String, dynamic> toJson() {
    return {
      'node_id': node_id,
      'room_id': room_id,
      'camera_action': camera_action,
      'duration': duration,
      'cmd_status': cmd_status.toJson()
    };
  }

  @Uint8()
  int node_id;
  @Uint8()
  int room_id;
  @Uint8()
  int camera_action;
  @Uint8()
  int duration;
  CmdStatus cmd_status;
}

/*
typedef struct {
  BYTE node_id; //node_id=0 means room_id, node_id = 1 means the //camera actions(recording, alarm, ....)
  BYTE room_id;
  BYTE camera_action; //camera actions, recording, spk alarm, //email/ftp, push alarm...
  BYTE duration; //WJF 20170226 changed to duration, binary //0xxxxxxx for seconds(1~120), 10xxxxxx for minutes(1~60), 11xxxxxx for hours(1~60)
  CMD_STATUS_T cmd_status; //if node_id > 1, the cmd_status is used
}
ZWAVE_ACTION_T;
*/
