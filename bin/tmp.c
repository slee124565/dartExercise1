#define  APP_ID_SIZE 4
#define  GW_ID_SIZE 3
typedef  struct {
    unsigned  char reserved;
    unsigned  char len; // this is ignored, no  used
    unsigned  char seq_no; // the response packet must copy this byte back
    unsigned  char opcode; // defined in LOCAL_SDK_OP_E
    unsigned  char version; // version = 1
    unsigned  char magic_id; // from gateway: 0x77, from App: 0x88
    unsigned  char gw_id[GW_ID_SIZE]; // 3 bytes of last mac address
    unsigned  char app_id[APP_ID_SIZE]; //random  id of App, changed fo  each request
    unsigned  char admin[20];
    unsigned  char password[20]; //password
    unsigned  char app_ip[4]; //ip address of the App
    unsigned  char app_port[2]; //App port
    unsigned  char reserved_for_gw[4];
    unsigned  char fail_code[4]; //for  SET_ANY_SETTING_OPERATION_FAIL_OP
    unsigned  int tlv_size; //network order, the total size of the following settings, not including blank and checksum
    unsigned  char settings[4]; //the settings concatenated in type length-value format
    unsigned  char empty; // set to 0
    unsigned  char checksum; // not used
}LOCAL_SDK_FORMAT_T

