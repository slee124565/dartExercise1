
import 'dart:typed_data';

class TLV {
  TLV({this.type, this.len, this.value});

  TLV.from_type_value({int type, Uint8List value}) {
    var _type = ByteData(2)
      ..setInt16(0, type);
    this.type = _type.buffer.asUint8List();
    if (value == null) {
      this.value = Uint8List.fromList([0, 0, 0, 0]);
    } else {
      this.value = value;
    }
    var _len = ByteData(2)
      ..setInt16(0, this.value.length);
    len = _len.buffer.asUint8List();
  }

  static List<TLV> from_settings(Uint8List pdu) {
    var _settings = <TLV>[];
    var n = 0;
    while ((n+4) < pdu.length) {
      var _len = ByteData.sublistView(pdu, n + 2, n + 4)
          .getUint16(0, Endian.big);
      var _type = ByteData.sublistView(pdu, n, n+2)
          .getUint16(0, Endian.big);
      print('tlv type $_type from ${pdu.sublist(n, n+2)}');
      print('tlv len $_len from ${pdu.sublist(n + 2, n + 4)}');
      print('tlv value ${pdu.sublist(n+4, n+4+_len)}');
      // print('tlv pdu ${pdu.sublist(n + 4, n + 4 + _len)}');
      if (_type > 0 || _len > 0) {
        _settings.add(TLV(
            type: pdu.sublist(n, n + 2),
            len: pdu.sublist(n + 2, n + 4),
            value: pdu.sublist(n + 4, n + 4 + _len)));
        n += (4 + _len);
        print('tlv type $_type added, n set to $n');
      } else {
        print('settings parsing break at type $_type, len $_len, '
            'n $n, pdu len ${pdu.length}');
        break;
      }
    }
    print('settings parsing return at n $n, pdu len ${pdu.length}');
    return _settings;
  }

  Uint8List type;
  Uint8List len;
  Uint8List value;

  Uint8List toBytes() {
    var data = BytesBuilder();
    data.add(type);
    data.add(len);
    data.add(value);
    return data.toBytes();
  }
}

