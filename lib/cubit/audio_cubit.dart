import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/service/audio_service.dart';
import 'package:tibetan_language_learning_app/util/exception.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioService audioService;
  AudioPlayer audioPlayer;
  AudioCubit(this.audioService, {required this.audioPlayer})
      : super(AudioInitial()) {
    initAudioListener();
  }

  Future<void> loadAudio(
      {required String pathName, required String fileName}) async {
    try {
      emit(AudioLoading());
      audioPlayer =
          await audioService.loadAudioFromPath(pathName, fileName, audioPlayer);
      emit(AudioLoaded(audioPlayer));
      //listenToAudio();
    } on AudioException catch (e) {
      print(e.error());
    }
  }

  Future<void> playAudio() async {
    await audioPlayer.play();
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await audioPlayer.seek(Duration.zero);
    pauseAudio();
  }

  void initAudioListener() {
    audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        print('listener: loading');
      } else if (!isPlaying) {
        print('listener: paused');
        emit(AudioPause());
      } else if (processingState != ProcessingState.completed) {
        emit(AudioPlaying());
        print('listener: playing');
      } else {
        print('listener: finished');
        emit(AudioStopped());
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
      }
    });
  }

  void toggleRepeatMode() {
    if (audioPlayer.loopMode == LoopMode.off) {
      audioPlayer.setLoopMode(LoopMode.one);
      emit(AudioRepeatOn());
    } else if (audioPlayer.loopMode == LoopMode.one) {
      audioPlayer.setLoopMode(LoopMode.off);
      emit(AudioRepeatOff());
    }
  }

  void destroyAudioPlayer() {
    audioPlayer.dispose();
  }
}
