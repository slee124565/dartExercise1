/*
  typedef struct {
  BYTE node_id; //node_id=0 means room_id, node_id = 1 means the //camera sensors(MD, sound, PIR, temperature)
  BYTE room_id;
  BYTE and_or; // and/or this event
  BYTE camera_event; //when node_id=1, camera trigger, MD, PIR, //temperature,...PNS_TRIGGERED_BY_E
  unsigned short remain_sec; //remain how many seconds to trigger //the action, 0 means immediately
  char compare; //bigger than, less than or match the //trigger_source/cmd_status
  BYTE reserved;
  time_t triggered_sec; //this is for camera internal usage, to store how //many seconds this event has happened
  CMD_STATUS_T cmd_status; //if node_id > 1, the cmd_status is used
}
ZWAVE_TRIGGER_EVENT_T;
*/

import 'dart:ffi';
import 'dart:typed_data';

import 'command_status_t.dart';

class ZWaveTriggerEvent {
  static int length = 40;

  ZWaveTriggerEvent.fromPdu(Uint8List pdu) {
    var n = 0;
    node_id = pdu[n++];
    room_id = pdu[n++];
    and_or = pdu[n++];
    camera_event = pdu[n++];
    remain_sec = ByteData.sublistView(pdu, n, n+2).getUint16(0);
    n += 2;
    compare = pdu[n++];
    reserved = pdu[n++];
    triggered_sec = ByteData.sublistView(pdu, n, n+4).getInt32(0);
    n += 4;
    cmd_status = CmdStatus.fromPdu(pdu.sublist(n));
    // print('parsing ZWaveTriggerEvent $pdu');
    // print('node_id ${node_id}');
    // print('room_id ${room_id}');
    // print('and_or ${and_or}');
    // print('camera_event ${camera_event}');
    // print('remain_sec ${remain_sec}');
    // print('compare ${compare}');
    // print('reserved ${reserved}');
    // print('triggered_sec ${triggered_sec}');
  }

  Map<String, dynamic> toJson() {
    return {
      'node_id': node_id,
      'room_id': room_id,
      'and_or': and_or,
      'camera_event': camera_event,
      'remain_sec': remain_sec,
      'compare': compare,
      'reserved': reserved,
      'triggered_sec': triggered_sec,
      'cmd_status': cmd_status.toJson(),
    };
  }

  @Uint8()
  int node_id;
  @Uint8()
  int room_id;
  @Uint8()
  int and_or;
  @Uint8()
  int camera_event;
  @Uint16()
  int  remain_sec;
  @Int8()
  int compare;
  @Uint8()
  int reserved;
  @Uint32()
  int triggered_sec;
  CmdStatus cmd_status;
}
