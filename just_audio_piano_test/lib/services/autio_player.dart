import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService._();

  static AudioPlayerService get instance => AudioPlayerService._();

  void play(String note) => AudioPlayer()
    ..setAsset("assets/audio/C3.mp3")
    ..play();
}
