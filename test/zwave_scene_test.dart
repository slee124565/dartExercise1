import 'dart:typed_data';

import 'package:dartExercise1/ccapi/local_sdk_format.dart';

import 'case_type_samples.dart';

void main() {
  var sdk_resp = LocalSdkFormat.fromBasePdu(
      Uint8List.fromList(kPDU_TYPE_ZWAVE_SCENE_GET_ALL_INFO_RESPONSE));
  var sdk_resp_scenes =
      ZwaveSceneGetAllInfoResponseSettings.fromSdkResponseSettings(
          sdk_resp.settings);
  for (var scene in sdk_resp_scenes.scenes) {
    print('scene id ${scene.scene_id}');
    print('${scene.toJson()}');
    print('');
  }
}
