
import 'dart:typed_data';

abstract class TLVStructBase {
  factory TLVStructBase.fromPdu(Uint8List pdu) {
    throw UnimplementedError('Not Implement');
  }
  TLVStructBase fromUint8List(Uint8List data);
  int get typeId;
}
