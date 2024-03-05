import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  int entryMood;
  List<dynamic> entryEmotions;
  String entryImageURL;
  String entryVoiceNoteURL;
  String entryText;
  Timestamp timestamp;

  JournalEntry({
    required this.entryMood,
    required this.entryEmotions,
    required this.entryImageURL,
    required this.entryVoiceNoteURL,
    required this.entryText,
    required this.timestamp,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      entryMood: map['entryMood'],
      entryEmotions: map['entryEmotions'] ?? [],
      entryImageURL: map['entryImageURL'],
      entryVoiceNoteURL: map['entryVoiceNoteURL'],
      entryText: map['entryText'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entryMood': entryMood,
      'entryEmotions': entryEmotions,
      'entryImageURL': entryImageURL,
      'entryVoiceNoteURL': entryVoiceNoteURL,
      'entryText': entryText,
      'timestamp': timestamp,
    };
  }
}
