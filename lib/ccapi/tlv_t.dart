import 'dart:convert';
import 'dart:typed_data';

import 'package:dartExercise1/ccapi/constants.dart';

import 'zwave_scene_t.dart';

class TLV {
  TLV({this.type, this.len, this.value});

  TLV.from_type_value({int type, Uint8List value}) {
    // print('from_type_value $value');
    var _type = ByteData(2)..setInt16(0, type);
    this.type = _type.buffer.asUint8List();
    this.value = value ?? Uint8List.fromList([0, 0, 0, 0]);
    // if (value == null) {
    //   print('from_type_value with null value');
    //   this.value = Uint8List.fromList([0, 0, 0, 0]);
    // } else {
    //   this.value = value;
    // }
    print('from_type_value ${this.value}');
    var _len = ByteData(2)..setInt16(0, this.value.length);
    len = _len.buffer.asUint8List();
  }

  factory TLV.zwave_scene_do_action({int scene_id}) {
    print('tlv set scene_id $scene_id');
    var _value = ByteData(4)..setInt32(0, scene_id);
    assert((0 < scene_id) && (scene_id < 0xff));
    return TLV.from_type_value(
        type: kTYPE_ZWAVE_SCENE_DO_ACTION, value: _value.buffer.asUint8List());
  }

  factory TLV.zwave_total_nodes() {
    return TLV.from_type_value(type: kTYPE_ZWAVE_TOTAL_NODES);
  }

  factory TLV.zwave_node_all_info() {
    // const kTYPE_ZWAVE_NODE_ALL_INFO = 207;
    return TLV.from_type_value(type: kTYPE_ZWAVE_NODE_ALL_INFO);
  }

  factory TLV.zwave_scene_get_all_info() {
    return TLV.from_type_value(type: kTYPE_ZWAVE_SCENE_GET_ALL_INFO);
  }

  factory TLV.fromPdu(Uint8List pdu) {
    var _len = pdu.sublist(2, 4).buffer.asInt16List()[0];
    assert(_len == (pdu.length - 4));
    // assert ();
    return TLV(
        type: pdu.sublist(0, 2),
        len: pdu.sublist(2, 4),
        value: pdu.sublist(4, pdu.length));
  }

  // static List<TLV> from_settings(Uint8List pdu) {
  //   var _settings = <TLV>[];
  //   var n = 0;
  //   while ((n + 4) < pdu.length) {
  //     var _len = ByteData.sublistView(pdu, n + 2, n + 4).getUint16(0);
  //     var _type = ByteData.sublistView(pdu, n, n + 2).getUint16(0);
  //     var _seq_no = ByteData.sublistView(pdu, n + 4, n + 8).getUint32(0);
  //     print('tlv type $_type from ${pdu.sublist(n, n + 2)}');
  //     print('tlv len $_len from ${pdu.sublist(n + 2, n + 4)}');
  //     print('tlv seq_no $_seq_no from ${pdu.sublist(n + 4, n + 8)}');
  //     print('tlv value ${pdu.sublist(n + 8, n + 4 + _len)}');
  //     // print('tlv pdu ${pdu.sublist(n + 4, n + 4 + _len)}');
  //     if (_type > 0 || _len > 0) {
  //       if (_type == kTYPE_ZWAVE_SCENE_GET_ALL_INFO) {
  //         var tlv_scene = ZWaveScene.fromPdu(pdu.sublist(n + 8, n + 4 + _len));
  //         // var zw_scene = ZWaveScene.fromPdu(pdu.sublist(n + 4, n + 4 + _len));
  //         print('scene id ${tlv_scene.scene_id} '
  //             'name ${Utf8Decoder().convert(tlv_scene.name)}');
  //         _settings.add(tlv_scene);
  //         // TLV(
  //         // type: pdu.sublist(n, n + 2),
  //         // len: pdu.sublist(n + 2, n + 4),
  //         // value: pdu.sublist(n + 4, n + 4 + _len)));
  //
  //       } else {
  //         _settings.add(TLV(
  //             type: pdu.sublist(n, n + 2),
  //             len: pdu.sublist(n + 2, n + 4),
  //             value: pdu.sublist(n + 4, n + 4 + _len)));
  //       }
  //       n += (4 + _len);
  //       // print('tlv type $_type added, n set to $n');
  //     } else {
  //       print('settings parsing break at type $_type, len $_len, '
  //           'n $n, pdu len ${pdu.length}');
  //       break;
  //     }
  //   }
  //   print('settings parsing return at n $n, pdu len ${pdu.length}');
  //   return _settings;
  // }

  Uint8List toBytes() {
    var data = BytesBuilder();
    data.add(type);
    data.add(len);
    data.add(value);
    return data.toBytes();
  }

  Uint8List type;
  Uint8List len;
  Uint8List value;
}
