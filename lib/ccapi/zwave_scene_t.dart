import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'constants.dart';
import 'event_trigger_time_t.dart';
import 'tlv_t.dart';
import 'zwave_action_t.dart';
import 'zwave_trigger_event_t.dart';

class ZWaveScene {
  ZWaveScene._();

  factory ZWaveScene.fromPdu(Uint8List pdu) {
    var obj = ZWaveScene._();
    var n = 0;
    obj.name = pdu.sublist(n, n + kMAX_SCENE_NAME_SIZE);
    n += kMAX_SCENE_NAME_SIZE;
    obj.scene_id = pdu[n++];
    obj.num_events = pdu[n++];
    obj.num_actions = pdu[n++];
    obj.disabled = pdu[n++];
    obj.scene_status = pdu[n++];
    obj.type_flag = pdu[n++];
    obj.added_function = pdu[n++];
    obj.reserved = pdu[n++];
    obj.time =
        EventTriggerTime.fromPdu(pdu.sublist(n, n + EventTriggerTime.length));
    n += EventTriggerTime.length;
    obj.events = [];
    var num = 0;
    while (num < obj.num_events) {
      obj.events.add(ZWaveTriggerEvent.fromPdu(
          pdu.sublist(n, n + ZWaveTriggerEvent.length)));
      n += ZWaveTriggerEvent.length;
      num++;
    }
    num = 0;
    obj.actions = [];
    while (num < obj.num_actions) {
      obj.actions.add(ZWaveAction.fromPdu(pdu.sublist(n, n + ZWaveAction.length)));
      n += ZWaveAction.length;
      num++;
    }
    if (n < pdu.length) {
      print('ZWaveScene fromPdu parsing remain pdu ${pdu.sublist(n)}');
    }
    return obj;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': Utf8Decoder().convert(name.sublist(0, name.indexOf(0))),
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
