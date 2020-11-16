import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'constants.dart';
import 'event_trigger_time_t.dart';
import 'tlv_t.dart';
import 'zwave_action_t.dart';
import 'zwave_trigger_event_t.dart';

class ZWaveScene extends TLV {
  ZWaveScene({Uint8List type, Uint8List len, Uint8List value})
      : super(type: type, len: len, value: value) {
    var n = 0;
    name = value.sublist(n, n + kMAX_SCENE_NAME_SIZE);
    n += kMAX_SCENE_NAME_SIZE;
    scene_id = value[n++];
    num_events = value[n++];
    num_actions = value[n++];
    disabled = value[n++];
    scene_status = value[n++];
    type_flag = value[n++];
    added_function = value[n++];
    reserved = value[n++];
    time =
        EventTriggerTime.fromPdu(value.sublist(n, n + EventTriggerTime.length));
    n += EventTriggerTime.length;
    events = [];
    var num = 0;
    while (num < num_events) {
      events.add(ZWaveTriggerEvent.fromPdu(
          value.sublist(n, n + ZWaveTriggerEvent.length)));
      n += ZWaveTriggerEvent.length;
      num++;
    }
    num = 0;
    actions = [];
    while (num < num_actions) {
      actions.add(ZWaveAction.fromPdu(value.sublist(n, n + ZWaveAction.length)));
      n += ZWaveAction.length;
      num++;
    }
    if (n < value.length) {
      print('ZWaveScene fromPdu parsing remain pdu ${value.sublist(n)}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': Utf8Decoder().convert(name),
      'scene_id': scene_id,
      'num_events': num_events,
      'num_actions': num_actions,
      'disabled': disabled,
      'scene_status': scene_status,
      'type_flag': type_flag,
      'added_function': added_function,
      'reserved': reserved,
      'time': time.toJson(),
      'events': [for (ZWaveTriggerEvent event in events) event.toJson()],
      'actions': [for (ZWaveAction action in actions) action.toJson()],
      'action_end_times': action_end_times,
    };
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
