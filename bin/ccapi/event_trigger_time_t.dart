/*
typedef struct {
  unsigned char weekday_flag; //[5]:Fri  [6]:Sat //bit[0]:sun  [1]:mon  [2]:tue  [3]:wed  [4]:thurs
  unsigned char schedule_method; //SCHEDULE_METHOD_MODE, //SCHEDULE_METHOD_ALWAYS,  SCHEDULE_METHOD_FIXED, //SCHEDULE_METHOD_EVERYDAY  or  SCHEDULE_METHOD_EVERYWEEK
  unsigned char house_mode; //when  the  schedule_method  is //SCHEDULE_METHOD_MODE,  can  have  many modes
  unsigned char reserved;
  time_t tStart_time;
  time_t tEnd_time;
}
EVENT_TRIGGER_TIME_T;
*/

import 'dart:ffi';

import 'dart:typed_data';

class EventTriggerTime {
  static int length = 12;

  EventTriggerTime.fromPdu(Uint8List pdu) {
    assert (pdu.length == EventTriggerTime.length);
    var n = 0;
    weekday_flag = pdu[n++];
    schedule_method = pdu[n++];
    house_mode = pdu[n++];
    reserved = pdu[n++];
    start_time = ByteData.sublistView(pdu,n, n+4).getInt32(0);
    n += 4;
    end_time = ByteData.sublistView(pdu,n, n+4).getInt32(0);
    print('parsing EventTriggerTime $pdu');
    print('weekday_flag $weekday_flag');
    print('schedule_method $schedule_method');
    print('house_mode $house_mode');
    print('reserved $reserved');
    print('start_time $start_time');
    print('end_time $end_time');
  }

  @Uint8()
  int weekday_flag;
  @Uint8()
  int schedule_method;
  @Uint8()
  int house_mode;
  @Uint8()
  int reserved;
  @Uint32()
  int start_time;
  @Uint32()
  int end_time;
}