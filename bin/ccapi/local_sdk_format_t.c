#define APP_ID_SIZE 4
#define GW_ID_SIZE 3
typedef struct {
  unsigned char reserved;
  unsigned char len; // this is ignored, not used
  unsigned char seq_no; // the response packet must copy this byte back
  unsigned char opcode; //SET_ANY_SETTING_REQ_OP or GET_ANY_SETTING_REQ_OP
  unsigned char version; // version = 1
  unsigned char magic_id; // gateway : 0x77, App : 0x88
  unsigned char gw_id[GW_ID_SIZE]; //3 bytes of last mac address
  unsigned char app_id[APP_ID_SIZE]; // random id of App, changed for each request
  unsigned char user_name[20];
  unsigned char pass_digest[20]; //first part of the sha256 digest, 20 bytes
  unsigned char reserved_for_gw[10];
  unsigned char fail_code; //for SET_ANY_SETTING_OPERATION_FAIL_OP
  unsigned int tlv_size; //network order, the total size of the following settings, not including blank and checksum
  unsigned char settings[4]; //the settings concaterated in type-length-value format
  unsigned char gmt_time[4]; //the date/time(4 bytes) of the GMT+0, the camera/gateway will allow message within 20 seconds
  unsigned char digest2[12]; //second part of the sha256 digest, 12 bytes
  unsigned char empty; // set to 0
  unsigned char checksum; // checksum is the sum of all the bytes from reserved to empty
}
LOCAL_SDK_FORMAT_T;