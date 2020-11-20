

import 'dart:ffi';

import 'dart:typed_data';

import 'package:dartExercise1/ccapi/cmd_status_t.dart';
import 'package:dartExercise1/ccapi/constants.dart';

class NodeAllInfo {
  NodeAllInfo._(){
   cmd_status = [];
  }

  factory NodeAllInfo.fromPdu(Uint8List pdu) {
    var obj = NodeAllInfo._();
    var n = 0;
    obj.capability = pdu[n++];
    obj.num_endpoints = pdu[n++];
    obj.inactive_hours = pdu[n++];
    obj.basic = pdu[n++];
    obj.generic = pdu[n++];
    obj.specific = pdu[n++];
    obj.node_id = pdu[n++];
    obj.node_name = pdu.sublist(n, n+kMAX_NODE_NAME_SIZE);
    n += kMAX_NODE_NAME_SIZE;
    obj.num_cmds = pdu[n++];
    while (n < pdu.length) {
      var cmd_status_len = pdu[n];
      obj.cmd_status.add(CmdStatus.fromPdu(pdu.sublist(n, n+cmd_status_len)));
      n += cmd_status_len;
    }

    return obj;
  }

  @Uint8()
  int capability;
  @Uint8()
  int num_endpoints;
  @Uint8()
  int inactive_hours;
  @Uint8()
  int basic;

  @Uint8()
  int generic;
  @Uint8()
  int specific;
  @Uint8()
  int node_id;
  Uint8List node_name;
  @Uint8()
  int num_cmds;
  List<CmdStatus> cmd_status;
}
/*
typedef struct {
  unsigned char capability;
  //only  bit  0x80  is  used(listening  flag), all  other  7
  //bits  can  be  used  for  other  purpose
  unsigned char num_endpoints;
  unsigned char inactive_hours; //security changed  to  num_endpoints
  //inactive  hours,  max  is  255,  warning
  //when  bigger  than  4,  think  inactive  if  bigger  than  24
  unsigned char basic;
  unsigned char generic;
  unsigned char specific;
  unsigned char node_id;
  unsigned char node_name[MAX_NODE_NAME_SIZE];
  unsigned char num_cmds;
  //number  of  cmd  status
  CMD_STATUS_T cmd_status[MAX_NODE_NUM_CMDS];
  //12  command  status
}
NODE_ALL_INFO_T;
* */