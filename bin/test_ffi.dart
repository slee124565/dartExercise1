import 'dart:ffi';

class SvLocalSdkFormatDatagram extends Struct {
  @Uint8()
  int reserved;

  @Uint8()
  int len;

  @Uint8()
  int seq_no;

  @Uint8()
  int opcode;

  @Uint8()
  int version;

  @Uint8()
  int magic_id;

  Pointer<Uint8> gw_id;

  Pointer<Uint8> app_id;

  Pointer<Uint8> admin;

  Pointer<Uint8> password;

  Pointer<Uint8> app_ip;

  Pointer<Uint8> app_port;

  Pointer<Uint8> reserved_for_gw;

  Pointer<Uint8> fail_code;

  @Uint32()
  int tlv_size;

  Pointer<Uint8> settings;

  @Uint8()
  int empty;

  @Uint8()
  int checksum;
}

// #define  APP_ID_SIZE 4
// #define  GW_ID_SIZE 3
// typedef  struct {
//     unsigned  char reserved;
//     unsigned  char len; // this is ignored, no  used
//     unsigned  char seq_no; // the response packet must copy this byte back
//     unsigned  char opcode; // defined in LOCAL_SDK_OP_E
//     unsigned  char version; // version = 1
//     unsigned  char magic_id; // from gateway: 0x77, from App: 0x88
//     unsigned  char gw_id[GW_ID_SIZE]; // 3 bytes of last mac address
//     unsigned  char app_id[APP_ID_SIZE]; //random  id of App, changed fo  each request
//     unsigned  char admin[20];
//     unsigned  char password[20]; //password
//     unsigned  char app_ip[4]; //ip address of the App
//     unsigned  char app_port[2]; //App port
//     unsigned  char reserved_for_gw[4];
//     unsigned  char fail_code[4]; //for  SET_ANY_SETTING_OPERATION_FAIL_OP
//     unsigned  int tlv_size; //network order, the total size of the following settings, not including blank and checksum
//     unsigned  char settings[4]; //the settings concatenated in type length-value format
//     unsigned  char empty; // set to 0
//     unsigned  char checksum; // not used
// }LOCAL_SDK_FORMAT_T

