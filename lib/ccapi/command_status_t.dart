// typedef  struct {
// unsigned  char  cmdLen  ;
// unsigned  char  cmd_class ;
// unsigned  char  cmd  ;
// unsigned  char  parameters[MAX_CMD_STATUS_SIZE+1]  ;
// }  CMD_STATUS_T  ;

import 'dart:ffi';

import 'dart:typed_data';

import 'constants.dart';

class CmdStatus {
  static int length = kMAX_CMD_STATUS_SIZE+4;

  CmdStatus.fromPdu(Uint8List pdu) {
    var n = 0;
    cmdLen = pdu[n++];
    cmd_class = pdu[n++];
    cmd = pdu[n++];
    parameters = pdu.sublist(n);
  }

  Map<String, dynamic> toJson() {
    return {
      'cmdLen': cmdLen,
      'cmd_class': cmd_class,
      'cmd': cmd,
      'parameters': parameters
    };
  }

  @Uint8()
  int cmdLen;
  @Uint8()
  int cmd_class;
  @Uint8()
  int cmd;
  Uint8List parameters;
}