import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hue/services/coloring_page_service.dart';

import '../model/journal_entry.dart';
import '../services/journal_service.dart';
import '../theme/colors.dart';

final JournalService _journalService = JournalService();
final ColoringPageService _coloringPageService = ColoringPageService();

class ScrapbookPage extends StatefulWidget {
  const ScrapbookPage({super.key, required this.date, required this.uid});

  final String date;
  final String uid;
  @override
  State<ScrapbookPage> createState() => _ScrapbookPageState();
}

class _ScrapbookPageState extends State<ScrapbookPage> {
  JournalEntry? _currentEntry;
  String _coloringPageUrl = '';
  late AudioPlayer audioPlayer;

  Future<void> playRecording(String url) async {
    try {
      Source urlSource = UrlSource(url);
      await audioPlayer.play(urlSource);
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error play recording: $e');
      }
    }
  }

  DateTime _getDateFromString(String dateString) {
    final parts = dateString.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.now();
  }

  String formatDateString(DateTime date) {
    final day = date.day.toString();
    final month = _getMonthName(date.month);
    final year = date.year.toString();
    return '$day $month, $year';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    super.initState();
    _fetchJournalEntry();
    _fetchColoringPageUrl();
  }

  Future<void> _fetchJournalEntry() async {
    final uid = widget.uid;
    final entry = await _journalService.fetchEntry(uid, widget.date);

    if (mounted) {
      setState(() {
        _currentEntry = entry.$2;
      });
    }
  }

  Future<void> _fetchColoringPageUrl() async {
    final pageUrl =
        await _coloringPageService.fetchImageUrlByDate(widget.uid, widget.date);
    if (pageUrl != null) {
      if (mounted) {
        setState(() {
          _coloringPageUrl = pageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customYellow,
      appBar: AppBar(
        title: Text(
          formatDateString(_getDateFromString(widget.date)),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: customLilac,
        foregroundColor: customWhite,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        toolbarHeight: MediaQuery.of(context).size.height / 7,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(1290, 250),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: customYellow, // Your screen background color
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                if (_currentEntry != null)
                  _buildEntryCard(
                      _currentEntry!, _coloringPageUrl, playRecording),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry, String pageUrl,
      Future<void> Function(String) playRecording) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          moodWidget(entry.entryMood),
          entry.entryImageURL == ""
              ? const SizedBox(height: 1)
              : imageWidget(entry.entryImageURL),
          const SizedBox(height: 20),
          entry.entryVoiceNoteURL == ""
              ? const SizedBox(height: 1)
              : voiceWidget(entry.entryVoiceNoteURL, playRecording),
          const SizedBox(height: 20),
          entry.entryText == ""
              ? const SizedBox(height: 1)
              : textWidget(entry.entryText),
          const SizedBox(height: 20),
          pageUrl == "" ? const SizedBox(height: 1) : colorWidget(pageUrl),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget moodWidget(int mood) {
    return Row(
      children: [
        Text(
          'How you were feeling: ',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
        ),
        Flexible(child: _buildMoodImage(mood)),
        Text(
          ' $mood/5',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildMoodImage(int mood) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/phase$mood.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

Widget textWidget(String text) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'What you were thinking:   ',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
      ),
      const SizedBox(height: 10),
      Text(
        text,
        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
      ),
    ],
  );
}

Widget imageWidget(String url) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          'What you were grateful for:   ',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
        ),
        const SizedBox(height: 10),
        Image.network(url),
      ]);
}

Widget voiceWidget(String url, Future<void> Function(String) playRecording) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          'What you were worrying about:   ',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                color: customPurple,
                iconSize: 40,
                onPressed: () => playRecording(url),
                icon: const Icon(Icons.play_arrow_rounded)),
            Flexible(
              child: Container(
                height: 2,
                width: 250,
                color: Colors.grey[500],
              ),
            )
          ],
        ),
      ]);
}

Widget colorWidget(String url) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          'What you created:   ',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
        ),
        const SizedBox(height: 10),
        Image.network(url),
      ]);
}
