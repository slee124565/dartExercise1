
import 'dart:ffi';

class LocalSdkFormat {
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