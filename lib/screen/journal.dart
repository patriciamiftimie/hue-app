import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hue/widgets/emoji_scale.dart';
import 'package:hue/widgets/gratitude_entry.dart';
import 'package:hue/widgets/reframe_entry.dart';
import 'package:hue/widgets/worry_entry.dart';
import '../model/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';

final UserProfileService _userProfileService = UserProfileService();
final JournalService _journalService = JournalService();

class JournalPage extends StatefulWidget {
  const JournalPage({super.key, required this.title, required this.uid});

  final String title;
  final String uid;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  JournalEntry? _currentEntry;
  String? _currentEntryId;
  int _entryMood = 0;
  String _entryImageUrl = "";
  String _entryVoiceNoteUrl = "";
  String _entryText = "";

  @override
  void initState() {
    super.initState();
    _fetchJournalEntry();
  }

  Future<void> _fetchJournalEntry() async {
    final uid = widget.uid;
    final entry = await _journalService.fetchEntry(uid, _getCurrentDate());

    if (mounted) {
      setState(() {
        _currentEntry = entry.$2;
        _currentEntryId = entry.$1;
      });
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'CBT Journal Entry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: customLilac,
        foregroundColor: customWhite,
        toolbarHeight: MediaQuery.of(context).size.height / 7,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(1290, 250),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            // Main column for different journal entry components
            children: [
              const SizedBox(
                height: 20,
              ),
              EmojiScale(uid: widget.uid, onRatingUpload: _handleMoodUpload),
              const SizedBox(
                height: 30,
              ),
              GratitudeEntry(
                  uid: widget.uid, onImageUpload: _handleImageUpload),
              const SizedBox(
                height: 30,
              ),
              WorryEntry(
                uid: widget.uid,
                onVoiceNoteUpload: _handleVoiceNoteUpload,
              ),
              const SizedBox(
                height: 30,
              ),
              ReframeEntry(uid: widget.uid, onTextUpload: _handleTextUpload),
              const SizedBox(
                height: 30,
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          _saveOrUpdateEntry();

          Navigator.pop(context);
        },
        heroTag: 'saveJournalEntry',
        backgroundColor: const Color(0xff735DA5),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Text(
          'Done',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  void _handleMoodUpload(int mood) {
    setState(() {
      if (_currentEntry != null) {
        _currentEntry!.entryMood = mood;
      } else {
        _entryMood = mood;
      }
    });
  }

  void _handleImageUpload(String imageUrl) {
    setState(() {
      if (_currentEntry != null) {
        _currentEntry!.entryImageURL = imageUrl;
      } else {
        _entryImageUrl = imageUrl;
      }
    });
  }

  void _handleVoiceNoteUpload(String voiceNoteUrl) {
    setState(() {
      if (_currentEntry != null) {
        _currentEntry!.entryVoiceNoteURL = voiceNoteUrl;
      } else {
        _entryVoiceNoteUrl = voiceNoteUrl;
      }
    });
  }

  void _handleTextUpload(String text) {
    setState(() {
      if (_currentEntry != null) {
        _currentEntry!.entryText = text;
      } else {
        _entryText = text;
      }
    });
  }

  Future<void> _saveOrUpdateEntry() async {
    final uid = widget.uid;
    if (_currentEntry != null) {
      await _journalService.updateEntry(_currentEntry!, uid, _currentEntryId!);
    } else {
      final newEntry = JournalEntry(
        entryMood: _entryMood,
        entryImageURL: _entryImageUrl,
        entryVoiceNoteURL: _entryVoiceNoteUrl,
        entryText: _entryText,
        timestamp: Timestamp.now(),
      );
      await _journalService.createEntry(newEntry, uid);
      updateCoins(5);
    }
    // Fetch the updated entry
    await _fetchJournalEntry();
  }

  Future<void> updateCoins(int coins) async {
    final uid = widget.uid;
    await _userProfileService.updateCoins(uid, coins);
  }
}
