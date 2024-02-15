import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_midi/flutter_midi.dart';
import 'package:piano/audio_services/audio_player.dart';
import 'package:piano/audio_services/note_calculator.dart';
import 'package:piano/audio_services/sequence_player.dart';
import 'package:tonic/tonic.dart';
import 'audio_services/sequence_strings.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';





void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  double get keyWidth => 80 + (80 * _widthRatio);
  double _widthRatio = 0.0;
  double _heightRatio = 0.0;
  bool _showLabels = true;
  bool _isRecording = false;
  final _audioRecorder = AudioRecorder();
  Timer? _timer;
  Duration _recordingDuration = Duration(); // Track the duration between current

  @override
  initState() {
    super.initState();
    _requestPermission();
    // AudioPlayerService.instance.loadAudio('B4');
  }


  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Piano APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
          drawer: Drawer(
              child: SafeArea(
                  child: ListView(children: <Widget>[
                    Container(height: 20.0),
                    ListTile(title: Text("Change Width")),
                    Slider(
                        activeColor: Colors.redAccent,
                        inactiveColor: Colors.white,
                        min: 0.0,
                        max: 0.5,
                        value: _widthRatio,
                        onChanged: (double value) =>
                            setState(() => _widthRatio = value)),
                    Divider(),
                    ListTile(title: Text("Change Height")), // New ListTile for height
                    Slider(
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.white,
                      min: 0.0,
                      max: 1.0, // Assuming a similar range as width
                      value: _heightRatio,
                      onChanged: (double value) {
                        setState(() {
                          _heightRatio = value;
                        });
                      },
                    ),
                    Divider(),
                    ListTile(
                        title: Text("Show Labels"),
                        trailing: Switch(
                            value: _showLabels,
                            onChanged: (bool value) =>
                                setState(() => _showLabels = value))),
                    Divider(),
                  ]))),
          appBar: AppBar(title: Text("Piano APP"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
              if (_isRecording) // only display during recording
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      "${_recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: _isRecording ? Colors.red : Colors.red,),
                  onPressed: () async {
                    if (_isRecording) {
                      // Stop recording

                    } else {
                      // Start recording

                    }
                    setState(() {
                      _isRecording = !_isRecording;
                      // Recording logic here
                    });
                  },
              tooltip: _isRecording ? 'Stop Recording' : 'Start Recording',
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: 7,
            controller: ScrollController(initialScrollOffset: 1500.0),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              final int i = index * 12;
              return SafeArea(
                child: Stack(children: <Widget>[
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    _buildKey(24 + i, false),
                    _buildKey(26 + i, false),
                    _buildKey(28 + i, false),
                    _buildKey(29 + i, false),
                    _buildKey(31 + i, false),
                    _buildKey(33 + i, false),
                    _buildKey(35 + i, false),
                  ]),
                  Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 150,
                      top: 0.0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(width: keyWidth * .5),
                            _buildKey(25 + i, true),
                            _buildKey(27 + i, true),
                            Container(width: keyWidth),
                            _buildKey(30 + i, true),
                            _buildKey(32 + i, true),
                            _buildKey(34 + i, true),
                            Container(width: keyWidth * .5),
                          ])),
                ]),
              );
            },
          )),
    );
  }

  Widget _buildKey(int midi, bool accidental) {
    final double verticalPadding = 0.0 + (50.0 * _heightRatio);
    final pitchName = NoteCalculator.instance.midi2name(midi);
    final pitchFileName = NoteCalculator.instance.midi2FileName(midi);

    final pianoKey = Stack(
      children: <Widget>[
        Semantics(
            button: true,
            hint: pitchName,
            child: Material(
                borderRadius: borderRadius,
                color: accidental ? Colors.black : Colors.white,
                child: InkWell(
                  borderRadius: borderRadius as BorderRadius,
                  highlightColor: Colors.grey,
                  // Change comment to play individual notes.
                  onTapDown: (_) => AudioPlayerService.instance.play(pitchFileName),
                  //onTapDown: (_) => SequencePlayer.instance.load(SequenceStrings.sequence1),
                ))),
        Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 100.0,
            child: _showLabels
                ? Text(pitchName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: !accidental ? Colors.black : Colors.white))
                : Container()),
      ],
    );
    if (accidental) {
      return Container(
          width: keyWidth,
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
          child: Material(
              elevation: 6.0,
              borderRadius: borderRadius,
              shadowColor: Color(0x802196F3),
              child: pianoKey));
    }
    return Container( 
        width: keyWidth,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: pianoKey,
        margin: EdgeInsets.symmetric(horizontal: 2.0)
    );

  }
}



const BorderRadiusGeometry borderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0));
