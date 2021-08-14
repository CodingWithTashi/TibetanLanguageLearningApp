import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/service/audio_service.dart';
import 'package:tibetan_language_learning_app/util/exception.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioService audioService;
  AudioPlayer audioPlayer;
  AudioCubit(this.audioService, {required this.audioPlayer})
      : super(AudioInitial());

  Future<void> loadAudio(String filePath) async {
    try {
      emit(AudioLoading());
      audioPlayer = await audioService.loadAudioFromPath(filePath, audioPlayer);
      emit(AudioLoaded(audioPlayer));
    } on AudioException catch (e) {
      print(e.error());
    }
  }

  void playAudio(AudioState state) {
    audioPlayer.play();
    emit(AudioPlay());
  }

  void pauseAudio() {
    audioPlayer.pause();
    emit(AudioPause());
  }
}
