import 'dart:developer';

import 'package:piano/audio_services/audio_player.dart';

class SequencePlayer {
  SequencePlayer._();
  static SequencePlayer get instance => SequencePlayer._();

  List<Set<String>> noteSetList = []; // List storing sets of notes that are played together
  List<int> durationList = []; // List storing the duration of the notes

  void load(String sequenceString) {

    // Splits the string by '/' and stores them in blocks.
    List<String> blockList = sequenceString.split('/'); 

    for (String block in blockList) {
      // Splits the block by '=' to separate the notes and duration.
      List<String> separatedBlock = block.split('=');

      // Splits the notes by '-' to store individual notes in a set.
      Set<String> noteSet = separatedBlock[0].split('-').toSet();

      
      noteSetList.add(noteSet); // Add individual note set to noteSetList
      durationList.add(int.parse(separatedBlock[1])); // Add duration to durationList
    }

    // Prints the lists for testing.
    log("List One: $noteSetList");
    log("List Two: $durationList");

    // Added play() in load() just to have it play the sequence automatically and test.
    // Playing the sequence will likely be called from a different widget.
    play();
  } 

  
    
  void play() async {  
    /** 
     * Iterate over noteSetList and play all notes in the set for the 
     * designated duration in durationList.
     */
    for (int i = 0; i < noteSetList.length; i++) {
      Set<String> noteSet = noteSetList[i];
      for (String note in noteSet) {
        AudioPlayerService.instance.play(note);
      }
      await Future.delayed(Duration(milliseconds: durationList[i]));
    }
  }
}
