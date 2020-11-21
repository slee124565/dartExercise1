

import 'dart:convert';
import 'dart:ffi';

import 'dart:typed_data';

import 'package:dartExercise1/ccapi/constants.dart';

class LocalRoom {
  LocalRoom._();

  factory LocalRoom.fromPdu(Uint8List pdu) {
    var obj = LocalRoom._();
    var n = 0;
    obj.name = pdu.sublist(n, n+kMAX_ROOM_NAME_SIZE);
    n += kMAX_ROOM_NAME_SIZE;
    obj.room_id = pdu[n++];
    obj.cam_id = pdu.sublist(n, n+3);
    n += 3;
    obj.temp_node_id = pdu[n++];
    obj.humi_node_id = pdu[n++];
    obj.lux_node_id = pdu[n++];
    obj.type_flag = pdu[n++];
    obj.reserved = pdu.sublist(n, n+3);
    n += 3;
    obj.num_nodes = pdu[n++];
    obj.node_id = pdu.sublist(n);
    return obj;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': Utf8Decoder().convert(name, 0, name.indexOf(0)),
      'room_id': room_id,
      'cam_id': cam_id,
      'temp_node_id': temp_node_id,
      'humi_node_id': humi_node_id,
      'lux_node_id': lux_node_id,
      'type_flag': type_flag,
      'reserved': reserved,
      'num_nodes': num_nodes,
      'node_id': node_id,
    };
  }

  Uint8List name;
  @Uint8()
  int room_id;
  Uint8List cam_id;
  @Uint8()
  int temp_node_id;
  @Uint8()
  int humi_node_id;
  @Uint8()
  int lux_node_id;
  @Uint8()
  int type_flag;
  Uint8List reserved;
  @Uint8()
  int num_nodes;
  Uint8List node_id;
}

/*
#define MAX_ROOM_NAME_SIZE 24
#define MAX_ALLOWED_NODES 60
#define MAX_ROOM_NODES MAX_ALLOWED_NODES + 2
//bigger  than  MAX_ALLOWED_NODES (MAX_ALLOWED_NODES+2)
typedef struct {
  unsigned char name[MAX_ROOM_NAME_SIZE];
  unsigned char room_id;
  //room  id  is  between  0~255,  room_id=0  is
  //always  for  room  0,  room  0  always  exist
  unsigned char cam_id[3];
  //  3  bytes  camera  id,  all  0  means  not  used
  unsigned char temp_node_id;
  unsigned char humi_node_id;
  unsigned char lux_node_id;
  unsigned char type_flag;
  unsigned char reserved[3];
  //temperature  node_id,  0  means  not  used
  //humidity node_id,  0  means  not  used
  //luminance  node_id,  0  means  not  used
  //type_flag  ==  0x77  for  group
  //for  some  later  usage,  like  the  room
  //environment  node_id  to  be  used,  set  this  to  zero  if  not  used
  unsigned char num_nodes;
  unsigned char node_id[MAX_ROOM_NODES];
  //the  node_id  of  this  room
}
ROOM_T;
 */