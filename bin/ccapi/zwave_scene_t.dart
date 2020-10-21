import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'constants.dart';
import 'event_trigger_time_t.dart';
import 'tlv_t.dart';
import 'zwave_action_t.dart';
import 'zwave_trigger_event_t.dart';

class ZWaveScene extends TLV {
  ZWaveScene.fromPdu(Uint8List pdu) {
    var n = 0;
    name = pdu.sublist(n, n + kMAX_SCENE_NAME_SIZE);
    n += kMAX_SCENE_NAME_SIZE;
    scene_id = pdu[n++];
    num_events = pdu[n++];
    num_actions = pdu[n++];
    disabled = pdu[n++];
    scene_status = pdu[n++];
    type_flag = pdu[n++];
    added_function = pdu[n++];
    reserved = pdu[n++];
    time =
        EventTriggerTime.fromPdu(pdu.sublist(n, n + EventTriggerTime.length));
    n += EventTriggerTime.length;
    events = [];
    var num = 0;
    while (num < num_events) {
      events.add(ZWaveTriggerEvent.fromPdu(
          pdu.sublist(n, n + ZWaveTriggerEvent.length)));
      n += ZWaveTriggerEvent.length;
      num++;
    }
    num = 0;
    actions = [];
    while (num < num_actions) {
      actions.add(ZWaveAction.fromPdu(
        pdu.sublist(n, n+ZWaveAction.length)
      ));
      n += ZWaveAction.length;
      num ++;
    }
    // action_end_times = Uint32List.sublistView([]);
    // while (n < pdu.length) {
    //   action_end_times.add(
    //     ByteData.sublistView(pdu, n, n+4)
    //         .buffer..asUint32List()[0]
    //   );
    // }
    print('parsing ZWaveScene $pdu');
    print('name ${Utf8Decoder().convert(name)}');
    print('scene_id $scene_id');
    print('num_events $num_events');
    print('num_actions $num_actions');
    print('disabled $disabled');
    print('scene_status $scene_status');
    print('type_flag $type_flag');
    print('added_function $added_function');
    print('reserved $reserved');
    // n += kMAX_SCENE_ACTIONS
    print('remain pdu ${pdu.sublist(n)}');
  }

  Uint8List name;
  @Uint8()
  int scene_id;
  @Uint8()
  int num_events;
  @Uint8()
  int num_actions;
  @Uint8()
  int disabled;
  @Uint8()
  int scene_status;
  @Uint8()
  int type_flag;
  @Uint8()
  int added_function;
  @Uint8()
  int reserved;
  EventTriggerTime time;
  List<ZWaveTriggerEvent> events;
  List<ZWaveAction> actions;
  Uint32List action_end_times;
}

void main() {
  const data = [
    232,
    135,
    165,
    229,
    174,
    164,
    229,
    133,
    168,
    233,
    150,
    139,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    2,
    5,
    1,
    0,
    0,
    0,
    0,
    0,
    8,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    9,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    7,
    98,
    3,
    0,
    16,
    2,
    254,
    254,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    10,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    9,
    113,
    5,
    0,
    0,
    0,
    255,
    7,
    8,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    13,
    2,
    0,
    0,
    0,
    3,
    37,
    1,
    255,
    15,
    9,
    0,
    48,
    0,
    119,
    1,
    225,
    142,
    173,
    79,
    95,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    3,
    0,
    0,
    0,
    3,
    37,
    1,
    255,
    15,
    1,
    2,
    48,
    0,
    119,
    1,
    212,
    196,
    173,
    79,
    95,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    24,
    0,
    0,
    0,
    3,
    64,
    1,
    2,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    24,
    0,
    0,
    0,
    5,
    67,
    1,
    2,
    1,
    26,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    24,
    0,
    0,
    0,
    3,
    68,
    1,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ];
  var zw_scene = ZWaveScene.fromPdu(Uint8List.fromList(data));
}
