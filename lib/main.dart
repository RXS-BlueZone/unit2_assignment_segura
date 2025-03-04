import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(MyMusicApp());

class MyMusicApp extends StatelessWidget {
  const MyMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit 2 Assignment - Music Player App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with WidgetsBindingObserver {
  AudioPlayer player = AudioPlayer();
  bool isCurrentlyPlaying = false; // for tracking playing state
  String currentTrack = ""; // for track url or file path of the audio file
  TextEditingController urlInputController = TextEditingController();

  // for observing lifecycle changes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    urlInputController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      player.pause(); // pause audio if app is in background
    } else if (state == AppLifecycleState.resumed) {
      if (isCurrentlyPlaying) {
        player.resume(); // resume if audio was playing before pause
      }
    }
  }

  /// file picker for picking audio file
  Future<void> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File audioFile = File(result.files.single.path!);
      startPlayback(audioFile.path, isFromFile: true);
    }
  }

  /// for playing the audio
  void startPlayback(String source, {bool isFromFile = false}) {
    Source audioSource =
        isFromFile ? DeviceFileSource(source) : UrlSource(source);

    setState(() {
      currentTrack = source;
      isCurrentlyPlaying = true;
    });
    player.play(audioSource);
  }

  /// button for toggling play and pause
  void toggleMusic() {
    setState(() {
      isCurrentlyPlaying = !isCurrentlyPlaying;
    });
    isCurrentlyPlaying ? player.resume() : player.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Music Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // display current track
            if (currentTrack.isNotEmpty)
              Text(
                'Current Track: ${Uri.parse(currentTrack).pathSegments.last}',
              ),
            if (currentTrack.isEmpty && !isCurrentlyPlaying)
              Padding(
                padding: const EdgeInsets.all(8), // Changed from 8.0 to 8
                child: Text(
                  'No audio file selected. Please pick an audio file or enter a URL.',
                ),
              ),
            Text(isCurrentlyPlaying ? 'Playing' : 'Paused'),
            ElevatedButton(
              onPressed: toggleMusic,
              child: Icon(isCurrentlyPlaying ? Icons.pause : Icons.play_arrow),
            ),
            SizedBox(height: 20),
            TextField(
              controller: urlInputController,
              decoration: InputDecoration(
                labelText: 'Enter song URL',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (urlInputController.text.isNotEmpty) {
                  startPlayback(urlInputController.text, isFromFile: false);
                }
              },
              child: Text("Play URL"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickAudioFile,
              child: Text("Pick File from Device"),
            ),
          ],
        ),
      ),
    );
  }
}
