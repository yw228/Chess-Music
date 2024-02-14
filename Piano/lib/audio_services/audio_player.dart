import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService._();
  static AudioPlayerService get instance => AudioPlayerService._();
  
  AudioPlayer audioPlayer = AudioPlayer();

  // void loadAudio(String note) => audioPlayer.setAsset("assets/audio/$note.mp3");

  // void play(String note) => audioPlayer.play();

  void play(String note) async {
    final player = AudioPlayer();
    await player.setAsset('assets/audio/$note.mp3');
    await player.play();
    player.stop();
  } 
}
