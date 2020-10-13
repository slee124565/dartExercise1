

import 'local_sdk_format.dart';


void main() {
  var tlv = TLV(type: TYPE_GATEWAY_LIST_ALL);
  print('${tlv.toBytes()}');
}