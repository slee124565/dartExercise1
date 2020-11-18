
import 'dart:ffi';

import 'dart:typed_data';

// import 'constants.dart';

const kMAX_CMD_STATUS_SIZE = 24;

class CmdStatus {

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

/*
#define  MAX_CMD_STATUS_SIZE  24
typedef struct {
  unsigned char cmdLen;
  unsigned char cmd_class;
  unsigned char cmd;
  unsigned char parameters[MAX_CMD_STATUS_SIZE + 1];
}
CMD_STATUS_T;
*/