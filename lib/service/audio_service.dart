import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/exception.dart';

class AudioService {
  Future<AudioPlayer> loadAudioFromPath(
      String pathName, String fileName, AudioPlayer audioPlayer) async {
    try {
      await audioPlayer.setAsset(ApplicationUtil.getAudioAssetPath(
          pathName: pathName, audioName: fileName));
    } on AudioException catch (e) {
      print(e.error());
    }
    return audioPlayer;
  }
}
