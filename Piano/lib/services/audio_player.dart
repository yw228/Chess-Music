import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService._();
  AudioPlayer audioPlayer = AudioPlayer();

  static AudioPlayerService get instance => AudioPlayerService._();

  // void loadAudio(String note) => audioPlayer.setAsset("assets/audio/$note.mp3");

  // void play(String note) => audioPlayer.play();

  void play(String note) async {
    final player = AudioPlayer();
    final duration = await player.setAsset('assets/audio/$note.mp3');                 // Schemes: (https: | file: | asset: )
    await player.play();
    player.stop();
  } 
}
