import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioDescriptionTask extends StatefulWidget {
  const AudioDescriptionTask({Key? key}) : super(key: key);

  @override
  _AudioDescriptionTaskState createState() => _AudioDescriptionTaskState();
}

class _AudioDescriptionTaskState extends State<AudioDescriptionTask> {
  bool _isRecording = false;
  bool _isFormSubmitted = false;
  bool _hasRecorded = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;
  String? _audioFileName;
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _checkSubmissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSubmitted = prefs.getBool('audioSubmitted') ?? false;
    final fileName = prefs.getString('audioFileName');
    
    setState(() {
      _isFormSubmitted = isSubmitted;
      _audioFileName = fileName;
      _hasRecorded = _isFormSubmitted;
    });
    
    if (_isFormSubmitted && _audioFileName != null) {
      await _prepareAudioPlayer();
    }
  }

  Future<void> _prepareAudioPlayer() async {
    if (_audioFileName == '') return;
    
    final directory = await getApplicationDocumentsDirectory();
    final audioPath = '${directory.path}/recordings/$_audioFileName';
    final file = File(audioPath);
    
    if (await file.exists()) {
      try {
        await _audioPlayer.setSource(DeviceFileSource(audioPath));
        final duration = await _audioPlayer.getDuration();
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      } catch (e) {
        print("Error setting audio source: $e");
        // Handle the error - maybe reset preferences if file is corrupted
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('audioFileName');
        await prefs.remove('audioSubmitted');
        setState(() {
          _audioFileName = '';
          _isFormSubmitted = false;
          _hasRecorded = false;
        });
      }
    } else {
      print("Audio file does not exist: $audioPath");
      // Reset preferences if file doesn't exist
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('audioFileName');
      await prefs.remove('audioSubmitted');
      setState(() {
        _audioFileName = '';
        _isFormSubmitted = false;
        _hasRecorded = false;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookie Theft Description'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_isFormSubmitted),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Cookie Theft Image Container
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: const FullscreenImageViewer(
                  imagePath: "assets/cookie_theft.jpg",
                ),
              ),
              const SizedBox(height: 30),
              
              // Show recording UI only if not submitted already
              if (!_isFormSubmitted) ...[
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isRecording ? 150 : 120,
                    height: _isRecording ? 150 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.grey.shade200,
                      border: Border.all(
                        color: _isRecording ? Colors.red.shade700 : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _toggleRecording(),
                        child: Center(
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 50,
                            color: _isRecording ? Colors.white : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _isRecording
                        ? 'Recording in progress...'
                        : _hasRecorded
                            ? 'Recording complete.'
                            : 'Tap to start recording',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isRecording ? Colors.red : Colors.black,
                      fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasRecorded
                        ? () {
                            _saveData();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Audio Recording Task'),
                                content: const Text('Recording session completed successfully!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Submit Recording',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Show playback UI if recording exists (either just recorded or previously submitted)
              //if (_hasRecorded && _audioFileName != '') _buildAudioPlayer(),
              if (_isFormSubmitted) _buildAudioPlayer(),
              
              // Only show reset button if form is already submitted
              //if (_hasRecorded && _audioFileName != '') ...[
              if (_isFormSubmitted) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _resetRecording(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Record New Audio',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetRecording() async {
    // Confirm with the user first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record New Audio'),
        content: const Text('This will delete your current recording. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Stop any playback
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      
      // Delete the old recording file
      if (_audioFileName != '') {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/recordings/$_audioFileName';
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting file: $e');
        }
      }
      
      // Reset shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('audioFileName');
      await prefs.remove('audioSubmitted');
      
      // Reset the state
      setState(() {
        _isFormSubmitted = false;
        _hasRecorded = false;
        _audioFileName = '';
        _recordingPath = '';
        _duration = Duration.zero;
        _position = Duration.zero;
      });
    }
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Playback",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  final newPosition = _position - const Duration(seconds: 5);
                  if (newPosition < Duration.zero) {
                    _audioPlayer.seek(Duration.zero);
                  } else {
                    _audioPlayer.seek(newPosition);
                  }
                },
                icon: const Icon(Icons.replay_5, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_playerState == PlayerState.playing) {
                    _audioPlayer.pause();
                  } else {
                    if (_playerState == PlayerState.paused) {
                      _audioPlayer.resume();
                    } else {
                      // If stopped or completed, restart from beginning
                      final directory = getApplicationDocumentsDirectory().then((dir) {
                        final audioPath = '${dir.path}/recordings/$_audioFileName';
                        _audioPlayer.play(DeviceFileSource(audioPath));
                      });
                    }
                  }
                },
                icon: Icon(
                  _playerState == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.black,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  final newPosition = _position + const Duration(seconds: 5);
                  if (newPosition > _duration) {
                    _audioPlayer.seek(_duration);
                  } else {
                    _audioPlayer.seek(newPosition);
                  }
                },
                icon: const Icon(
                  Icons.forward_5,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _position.inSeconds.toDouble(),
            min: 0,
            max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
            onChanged: (value) {
              final newPosition = Duration(seconds: value.toInt());
              _audioPlayer.seek(newPosition);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _hasRecorded = true;
        _recordingPath = path;
      });
      print('Recording saved to: $_recordingPath');
      
      // Prepare the audio player with the new recording
      if (path != null) {
        await _audioPlayer.setSource(DeviceFileSource(path));
        final duration = await _audioPlayer.getDuration();
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    } else {
      if (!await Permission.microphone.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      final patientName = prefs.getString('name') ?? 'unknown';

      _audioFileName =
          '${patientName}_cookie_theft_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${recordingsDir.path}/$_audioFileName';

      print('Starting recording to path: $path');

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audioSubmitted', true);
    await prefs.setString('audioFileName', _audioFileName!);
    setState(() {
      _isFormSubmitted = true;
    });
  }
}

class FullscreenImageViewer extends StatelessWidget {
  final String imagePath;

  const FullscreenImageViewer({Key? key, required this.imagePath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              body: SafeArea(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      return Center(
                        child: Image.asset(imagePath, fit: BoxFit.contain),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          imagePath,
          height: 150,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
