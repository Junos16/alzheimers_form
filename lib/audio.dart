import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
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
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30), // Space for floating header
                  // Description text
                  /*const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'This task involves describing the Cookie Theft picture. The patient should describe everything they see in the image in as much detail as possible.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),*/

                  // Placeholder image
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                      child: Text(
                        'Cookie Theft Image\n(Placeholder)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Recording button
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isRecording ? 150 : 120,
                      height: _isRecording ? 150 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : Colors.grey.shade200,
                        border: Border.all(
                          color:
                              _isRecording ? Colors.red.shade700 : Colors.grey,
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

                  // Recording status text
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
                        fontWeight:
                            _isRecording ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _hasRecorded
                              ? () {
                                _saveData();
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          'Audio Recording Task',
                                        ),
                                        content: const Text(
                                          'Recording session completed successfully!',
                                        ),
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
              ),
            ),

            // Floating header
            /*Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cookie Theft Description Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _hasRecorded = true;
        _recordingPath = path;
      });
      print('Recording saved to: $_recordingPath');
    } else {
      if (!await Permission.microphone.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        return;
      }

      // Get a directory for storing the audio file
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final filename =
          'cookie_theft_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${recordingsDir.path}/$filename';

      print('Starting recording to path: $path');

      // Start recording
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
    setState(() {
      _isFormSubmitted = true;
    });
  }
}
