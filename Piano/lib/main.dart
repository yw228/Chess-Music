import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  final _audioPlayer = AudioPlayer();
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;
  int _countdownTime = 0;
  String audioPath = 'assets/audio';

  @override
  initState() {
    super.initState();
  }

  void _startCountdown(bool permission) async {
    _countdownTime = 3; // Reset countdown time to 3
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownTime > 0) {
        setState(() {
          _countdownTime--;
        });
      } else {
        timer.cancel(); // Stop the timer
        _startRecording(permission); // Start recording
      }
    });
  }


  Future<void> _startRecording(bool permission) async {
    // Ensure you have permission before starting
    bool hasPermission = permission;
    if (hasPermission) {
      // Start recording logic...
      print("Permission granted. Starting recording...");
      _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: audioPath);
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        // Initialize or reset your recording duration timer here if needed
      });
      print("Recording started successfully.");
      _timer?.cancel(); // Cancel any existing timer
      _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          _recordingDuration += Duration(seconds: 1);
        });
      });
    }
    else {
      print("Permission denied. Cannot start recording.");
    }
  }
/*
  Future<void> playRecording() async{
    try{
      Source url
      await _audioPlayer.play()
    }
        catch(e) {
      print("Error playing Recording : $e");
    }
  }
*/
  Future<void> _stopRecording() async {
    String? path = await _audioRecorder.stop();
    await _audioRecorder.stop();
    // Cancel the timer to stop updating the recording duration
    _timer?.cancel();
    // Output the final duration of the recording to the console
    print("Recording stopped. Final duration: ${_recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}");
    setState(() {
      _isRecording = false;
      audioPath = path!;
    });
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
          drawer: Drawer(
              child: SafeArea(
                  child: ListView(children: <Widget>[
                    Container(height: 20.0),
                    const ListTile(title: Text("Change Width")),
                    Slider(
                        activeColor: Colors.redAccent,
                        inactiveColor: Colors.white,
                        min: 0.0,
                        max: 0.5,
                        value: _widthRatio,
                        onChanged: (double value) =>
                            setState(() => _widthRatio = value)),
                    const Divider(),
                    const ListTile(title: Text("Change Height")), // New ListTile for height
                    Slider(
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.white,
                      min: 0.0,
                      max: 1.0, // Assuming a similar range as width
                      value: _heightRatio,
                      onChanged: (double value) =>
                        setState(() => _heightRatio = value)),
                    const Divider(),
                    ListTile(
                        title: const Text("Show Labels"),
                        trailing: Switch(
                            value: _showLabels,
                            onChanged: (bool value) =>
                                setState(() => _showLabels = value))),
                    const Divider(),
                  ]))),
          appBar: AppBar(title: const Text("Chess Music"),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
              // Conditionally display countdown or recording duration
              if (_countdownTime > 0) // Display countdown before recording starts
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      "Starting in $_countdownTime",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else if (_isRecording) // Display during recording
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      "${_recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: _isRecording ? Colors.red : Colors.red,
                  ),
                  onPressed: () async {
                    if (_isRecording) {
                      // Stop recording
                      _stopRecording();
                    // await _audioRecorder.stop();

                    setState(() {
                      _isRecording = false;
                      _countdownTime = 3;
                      // Reset countdown time after stopping recording
                    });
                    } else {
                      final bool hasPermission = await _requestPermission();
                      if (hasPermission)
                        {
                          _startCountdown(hasPermission);
                        }
                      else {
                        print("Microphone permission denied. Cannot start recording.");
                      }
                    }
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

    final pitchName = NoteCalculator.instance.midi2name(midi);
    final pitchFileName = NoteCalculator.instance.midi2FileName(midi);

    // Define base heights for white and black keys
    final double baseWhiteKeyHeight = 500.0; // Example base height for white keys
    final double baseBlackKeyHeight = 400.0; // Example base height for black keys

    // Calculate actual heights using _heightRatio
    final double whiteKeyHeight = baseWhiteKeyHeight + (300 * _heightRatio);
    final double blackKeyHeight = baseBlackKeyHeight + (baseBlackKeyHeight * _heightRatio);

    // Determine the key height based on whether it's an accidental or not
    final double keyHeight = accidental ? blackKeyHeight : whiteKeyHeight;

    final pianoKey = Container(
      height: keyHeight,
        child: Stack(
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
                    color: !accidental ? Colors.black : Colors.white, fontSize: 16))
                : Container()),
      ],),
    );

    if (accidental) {
      // Use Transform.translate to move the black keys up
      return Transform.translate(
        offset: Offset(0, -150), // will have to adjust it according to the device
        child: Container(
            width: keyWidth,
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
            child: Material(
                elevation: 6.0,
                borderRadius: borderRadius,
                shadowColor: Color(0x802196F3),
                child: pianoKey)),
      );
    }
    return Container( 
        width: keyWidth,
        child: pianoKey,
        margin: EdgeInsets.symmetric(horizontal: 2.0)
    );
  }
}
const BorderRadiusGeometry borderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0));
