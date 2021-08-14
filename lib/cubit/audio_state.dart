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

class AudioPlay extends AudioState {
  const AudioPlay();
}

class AudioPause extends AudioState {
  const AudioPause();
}

class AudioStopped extends AudioState {
  const AudioStopped();
}

class AudioFinish extends AudioState {
  const AudioFinish();
}

class AudioRepeat extends AudioState {
  const AudioRepeat();
}
