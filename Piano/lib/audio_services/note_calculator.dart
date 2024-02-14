class NoteCalculator {
  NoteCalculator._();

  static NoteCalculator get instance => NoteCalculator._();

  final List<String> flatNoteNames = [
    'C',
    'D♭',
    'D',
    'E♭',
    'E',
    'F',
    'G♭',
    'G',
    'A♭',
    'A',
    'B♭',
    'B'
  ];

  final List<String> flatNoteFileNames = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B'
  ];

  String midi2name(int number) {
    return "${flatNoteNames[number % 12]}${number ~/ 12 - 1}";
  }

  String midi2FileName(int number) {
    return "${flatNoteFileNames[number % 12]}${number ~/ 12 - 1}";
  }
}
