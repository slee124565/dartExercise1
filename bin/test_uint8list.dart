
import 'dart:typed_data';

void main() {
  var data = BytesBuilder();
  data.add(Uint8List.fromList([1,2,3,4]));
  data.add(Uint8List.fromList([5,6,7,8]));
  print(data.toBytes());
}