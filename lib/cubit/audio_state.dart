part of 'audio_cubit.dart';

abstract class AudioState {
  const AudioState();
}

class AudioLoading extends AudioState {
  AudioLoading();
}

class AudioInitial extends AudioState {
  const AudioInitial();
}

class AudioLoaded extends AudioState {
  final AudioPlayer audio;
  AudioLoaded(this.audio);
}
