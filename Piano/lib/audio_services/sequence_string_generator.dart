class SequenceStringGenerator {
  String sequenceString = "";

  // Generates a sequence string with note set list and duration list.
  String generateSequenceString(List<Set<String>> noteSetList, List<int> durationList) {
    for (int i = 0; i < noteSetList.length; i++) {
      addBlock(noteSetList[i], durationList[i]);
    }
    return sequenceString;
  }
   
  // Adds a block (note set and duration) to the sequence string.
  void addBlock(Set<String> noteSet, int duration) {
    String noteString = "";

    // Iterate over notes in note set
    for (String note in noteSet) {
      // Add individual notes to note string, only add '-' when not first note
      if (noteString == "") {
        noteString = note;
      }
      else {
        noteString = "$noteString-$note";
      }
    }

    // Convert int duration to string
    String durationString = duration.toString();
    // Combine note string and duration string into block
    String blockString = "$noteString=$durationString";

    // Add block to sequence, only add '/' when not first block
    if (sequenceString == "") {
      sequenceString = blockString;
    }
    else {
      sequenceString = "$sequenceString/$blockString";
    }
  }

  // Returns current sequence string.
  String getSequenceString() {
    return sequenceString;
  }
}