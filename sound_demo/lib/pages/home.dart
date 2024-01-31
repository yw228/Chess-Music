import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
// import 'package:just_audio/just_audio.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sound Demo'),
        backgroundColor: const Color.fromARGB(255, 76, 175, 145),
      ),
      body: Column(
        children: [
          Expanded(
            child: ButtonGrid(),
          ),
          ElevatedButton(
            onPressed: () {
              playChord('C3', 'E3', 'G3');
            }, 
            child: const Text('Chord'),
          ),
          ElevatedButton(
            onPressed: () {
              playScale('C3', 'D3', 'E3', 'F3', 'G3');
            }, 
            child: const Text('Scale'),
          ),
          const ChordPlayer(note1: 'C3', note2: 'E3', note3: 'G3'),
          const VolumeSlider(),
        ],
      ),
    );
  }
}

class VolumeSlider extends StatefulWidget {
  const  VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => VolumeSliderState();
}

class VolumeSliderState extends State<VolumeSlider> {
  double volume = 50;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: volume,
      max: 100,
      divisions: 100,
      label: volume.round().toString(),
      onChanged: (double value) {
        setState(() {
          volume = value;
        });
      },
    );
  }
}

void playChord(String note1, String note2, String note3) async {
  log("playing chord $note1, $note2, $note3,");
  final player1 = AudioPlayer();
  final player2 = AudioPlayer();
  final player3 = AudioPlayer();

  await player1.play(AssetSource('notes/$note1.wav'));
  await player2.play(AssetSource('notes/$note2.wav'));
  await player3.play(AssetSource('notes/$note3.wav'));

  Timer(const Duration(seconds: 4), () {
    player1.stop();
    player2.stop();
    player3.stop();
  });
}

// void playChord(String note1, String note2, String note3) async {
//   log("playing chord $note1, $note2, $note3,");
//   final player1 = AudioPlayer(); await player1.setAsset('assets/notes/$note1.mp3');
//   final player2 = AudioPlayer(); await player2.setAsset('assets/notes/$note2.mp3');
//   final player3 = AudioPlayer(); await player3.setAsset('assets/notes/$note3.mp3');

//   player1.play();
//   player2.play();
//   player3.play();

//   Timer(const Duration(seconds: 4), () {
//     player1.stop();
//     player2.stop();
//     player3.stop();
//   });
// }

void playScale(String note1, String note2, String note3, String note4, String note5,) async {
  log("playing scale $note1, $note2, $note3, $note4, $note5,");
  final List<String> scale = ['C3', 'D3', 'E3', 'F3', 'G3'];
  List<AudioPlayer> players = [AudioPlayer(), AudioPlayer(), AudioPlayer(), AudioPlayer(), AudioPlayer()];

  for (int i = 0; i < scale.length; i++) {
    players[i].play(AssetSource('notes/${scale[i]}.wav'));
    await Future.delayed(const Duration(seconds: 1));
    Timer(const Duration(seconds: 4), () {
      players[i].dispose();
    });
  }
}

void playNote(String note) {
  log("playing note $note");
  final player = AudioPlayer();
  player.play(AssetSource('notes/$note.wav'));
  Timer(const Duration(seconds: 4), () {
    // player.stop();
    player.dispose();
  });
}

class ButtonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 49,
      itemBuilder: (context, index) {
        int row = index ~/ 7;
        int col = index % 7;
        List<String> scale = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        String label = (scale[col]) + (row + 1).toString();
        return Padding(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
            onPressed: () {
              playNote(label);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0),
            ),
            child: AutoSizeText(
              label,
              style: const TextStyle(fontSize: 0),
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }
}

class ChordPlayer extends StatefulWidget {
  final String note1, note2, note3;

  const ChordPlayer({
    Key? key,
    required this.note1,
    required this.note2,
    required this.note3,
  }) : super(key: key);

  @override
  State<ChordPlayer> createState() => ChordPlayerState();
}

class ChordPlayerState extends State<ChordPlayer> {
  late AudioPlayer player1, player2, player3;
  
  @override
  void initState() {
    super.initState();
    player1 = AudioPlayer();
    player2 = AudioPlayer();
    player3 = AudioPlayer();
    preloadNotes();
  }

  void preloadNotes() {
    player1.setSource(AssetSource('notes/${widget.note1}.wav'));
    player2.setSource(AssetSource('notes/${widget.note2}.wav'));
    player3.setSource(AssetSource('notes/${widget.note3}.wav'));
  }

  void playChord() {
    player1.resume();
    player2.resume();
    player3.resume();

    Timer(const Duration(seconds: 4), () {
      player1.stop();
      player2.stop();
      player3.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: playChord,
      child: const Text('Chord Using Preload'),
    );
  }
}