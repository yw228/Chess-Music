import 'package:just_audio/just_audio.dart';
import 'package:piano/services/audio_player.dart';

// Difficult to generate with piano input
// Difficult to alter
// Difficult to pause and replay mid-sequence

class SequencePlayer {
  SequencePlayer._();
  AudioPlayer audioPlayer = AudioPlayer();

  static SequencePlayer get instance => SequencePlayer._();

  List<Set<String>> noteList = [];
  List<int> durationList = [];

  void load(String noteSequence) {
    String temp = "";
    bool toggle = true;

    for (int i = 0; i < noteSequence.length; i++) {
      if (noteSequence[i] == '/' || i == noteSequence.length - 1) {
        if (noteSequence[i] != '/') {
          temp += noteSequence[i];
        }

        if (toggle) {
          List<String> individualNoteList = temp.split('-');
          Set<String> noteSet = individualNoteList.toSet();
          noteList.add(noteSet);
        } else {
          durationList.add(int.parse(temp));
        }

        temp = "";
        toggle = !toggle;
      } else {
        temp += noteSequence[i];
      }
    }
    print("List One: $noteList");
    print("List Two: $durationList");
    play();
  } 

    
  void play() async {  
    for (int i = 0; i < noteList.length; i++) {
      Set<String> noteSet = noteList[i];
      for (String note in noteSet) {
        AudioPlayerService.instance.play(note);
      }
      await Future.delayed(Duration(milliseconds: durationList[i]));
    }
  }
}
