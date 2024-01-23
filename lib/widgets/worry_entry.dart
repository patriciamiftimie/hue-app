import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../services/journal_service.dart';

class WorryEntry extends StatefulWidget {
  const WorryEntry(
      {super.key, required this.uid, required this.onVoiceNoteUpload});
  final String uid;
  final Function(String) onVoiceNoteUpload;

  @override
  State<WorryEntry> createState() => _WorryEntryState();
}

class _WorryEntryState extends State<WorryEntry> {
  String? _recordingUrl;
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;

  String _getDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  Future<String?> uploadRecording(File file, String uid, String date) async {
    try {
      if (file.existsSync()) {
        String fileName =
            '$date.wav'; // Ensure you use the correct file extension
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('$uid/worry_recordings/$fileName');
        UploadTask uploadTask = storageReference.putFile(file);
        await uploadTask.whenComplete(() {});

        // Get the download URL after the upload is complete
        String downloadUrl = await storageReference.getDownloadURL();
        return downloadUrl;
      } else {
        print('File does not exist: ${file.path}');
        return null;
      }
    } catch (e) {
      print('Error uploading recording: $e');
      return null;
    }
  }

  Future<void> _fetchUserRecordingURL() async {
    final userRecordingURL =
        await JournalService().fetchUserVoiceNoteURL(widget.uid);

    setState(() {
      _recordingUrl = userRecordingURL;
    });
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = AudioRecorder();
    super.initState();
    _fetchUserRecordingURL();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audioRecord.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        var path = directory.path;
        await audioRecord.start(const RecordConfig(), path: path);
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print('Error start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      if (path != null) {
        String? recordingUrl =
            await uploadRecording(File(path), widget.uid, _getDate());
        if (mounted) {
          setState(() {
            isRecording = false;
            _recordingUrl = recordingUrl;
          });
        }
      }
    } catch (e) {
      print('Error stop recording: $e');
    }
  }

  Future<void> playRecording() async {
    try {
      Source urlSource = UrlSource(_recordingUrl!);
      await audioPlayer.play(urlSource);
      setState(() {});
    } catch (e) {
      print('Error play recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you worried about?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
          ),
          const SizedBox(height: 10),
          _recordingUrl == null || _recordingUrl == ""
              ? const SizedBox(height: 1)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        color: customPurple,
                        iconSize: 40,
                        onPressed: playRecording,
                        icon: const Icon(Icons.play_arrow_rounded)),
                    Container(
                      height: 2, // Adjust the height of the line as needed
                      width: 280, // Adjust the width of the line as needed
                      color: Colors.grey[500],
                    ),
                  ],
                ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  onPressed: isRecording ? stopRecording : startRecording,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customYellow,
                      foregroundColor: customPurple),
                  child: isRecording
                      ? const Icon(Icons.pause_rounded)
                      : const Icon(Icons.mic_rounded)),
              if (isRecording) const Text('Recording...'),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                  onPressed: () {
                    widget.onVoiceNoteUpload(_recordingUrl!);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customYellow,
                      foregroundColor: customPurple),
                  child: const Text("Add new voice note"))
            ],
          ),
        ],
      ),
    );
  }
}
