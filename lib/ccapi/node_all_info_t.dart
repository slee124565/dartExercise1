import 'dart:convert';
import 'dart:ffi';

import 'dart:typed_data';

import 'package:dartExercise1/ccapi/cmd_status_t.dart';
import 'package:dartExercise1/ccapi/constants.dart';

class NodeAllInfo {
  NodeAllInfo._() {
    cmd_status = [];
  }

  factory NodeAllInfo.fromPdu(Uint8List pdu) {
    print('node pdu $pdu');
    var obj = NodeAllInfo._();
    var n = 0;
    obj.capability = pdu[n++];
    obj.num_endpoints = pdu[n++];
    obj.inactive_hours = pdu[n++];
    obj.basic = pdu[n++];
    obj.generic = pdu[n++];
    obj.specific = pdu[n++];
    obj.node_id = pdu[n++];
    obj.node_name = pdu.sublist(n, n + kMAX_NODE_NAME_SIZE);
    n += kMAX_NODE_NAME_SIZE;
    obj.num_cmds = pdu[n++];
    while (n < pdu.length) {
      obj.cmd_status
          .add(CmdStatus.fromPdu(pdu.sublist(n, n + 4 + kMAX_CMD_STATUS_SIZE)));
      n += 4 + kMAX_CMD_STATUS_SIZE;
    }

    return obj;
  }

  Map<String, dynamic> toJons() {
    return {
      'capability': capability,
      'num_endpoints': num_endpoints,
      'inactive_hours': inactive_hours,
      'basic': basic,
      'generic': generic,
      'specific': specific,
      'node_id': node_id,
      'node_name':
          Utf8Decoder().convert(node_name.sublist(0, node_name.indexOf(0))),
      'num_cmds': num_cmds,
      'cmd_status': [for (var cmd in cmd_status) '${cmd.toJson()}'],
    };
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
}NODE_ALL_INFO_T;
MAX_NODE_NAME_SIZE = 20;

[
211 capability,
0 num_endpoints,
0 inactive_hours,
4 basic, 16 generic, 1 specific,
2 node_id,
233, 150, 147, 231, 133, 167, 0, 0, 119, 105, 99, 104, 49, 0, 0, 0, 0, 0, 0, 0,
7,
3, 37, 3, 255, 15, 9, 0, 48, 0, 119, 1, 225, 142, 173, 79, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 50, 2, 33, 50, 1, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 50, 2, 33, 68, 0, 0, 3, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 114, 5, 1, 15, 4, 3, 48, 0, 119, 3, 205, 5, 205, 45, 50, 181, 95, 180, 95, 0, 0, 0, 0, 0, 0, 0, 0, 4, 115, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 32, 1, 255, 204, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 112, 6, 20, 1, 2, 230, 6, 181, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
* */
