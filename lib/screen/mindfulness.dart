import 'package:flutter/material.dart';
import 'package:hue/services/openai_api_key.dart';

import '../model/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import 'package:dart_openai/dart_openai.dart';

final UserProfileService _userProfileService = UserProfileService();
final JournalService _journalService = JournalService();

class MindfulnessPage extends StatefulWidget {
  const MindfulnessPage({super.key, required this.title, required this.uid});

  final String title;
  final String uid;

  @override
  State<MindfulnessPage> createState() => _MindfulnessPageState();
}

class _MindfulnessPageState extends State<MindfulnessPage> {
  String _userName = '';
  List<dynamic> _emotions = [];
  String _emotionsText = '';
  String _exercise = '';
  JournalEntry? _journalEntry;
  bool _isGeneratingExercise = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchJournalEntry();
  }

  Future<void> _fetchJournalEntry() async {
    final uid = widget.uid;
    final entry = await _journalService.fetchEntry(uid, _getCurrentDate());

    if (mounted) {
      setState(() {
        _journalEntry = entry.$2;
        if (_journalEntry != null) {
          _emotions = entry.$2!.entryEmotions;
          _generateExercise();
        }
      });
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  Future<void> _fetchUserName() async {
    final uid = widget.uid;
    final name = await _userProfileService.fetchUserName(uid);

    if (mounted) {
      setState(() {
        _userName = name!;
      });
    }
  }

  Future<void> _generateExercise() async {
    setState(() {
      _isGeneratingExercise = true;
    });

    OpenAI.apiKey = OpenAIApiKey.openAIApiKey;
    String textToRemoveFromStart =
        "[OpenAIChatCompletionChoiceMessageContentItemModel(type: text, text: ";
    String textToRemoveFromEnd = ", imageUrl: null)]";

    if (_emotions.isNotEmpty) {
      if (_emotions.length == 1) {
        _emotionsText = _emotions.first.toString();
      } else {
        _emotionsText =
            '${_emotions.sublist(0, _emotions.length - 1).join(', ')} and ${_emotions.last}';
      }
    } else {
      _emotionsText = '';
    }

    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-4',
      messages: [
        OpenAIChatCompletionChoiceMessageModel.fromMap({
          "role": "user",
          "content":
              "Hi, my name is $_userName. Can you please propose a short and easy mindful exercise for me to do right now when i'm feeling $_emotionsText? Something that you can explain very quickly and it can be physical, mental, breathing or anything else. Just say hi to me and start straight with the exercise without anything else."
        })
      ],
    );

    String result = removeTextFromStartAndEnd(
        completion.choices[0].message.content.toString(),
        textToRemoveFromStart,
        textToRemoveFromEnd);
    setState(() {
      _exercise = result;
      _isGeneratingExercise = false;
    });
  }

  String removeTextFromStartAndEnd(String originalString,
      String textToRemoveFromStart, String textToRemoveFromEnd) {
    String result = originalString;

    if (result.startsWith(textToRemoveFromStart)) {
      result = result.replaceFirst(textToRemoveFromStart, '');
    }

    if (result.endsWith(textToRemoveFromEnd)) {
      int endIndex = result.lastIndexOf(textToRemoveFromEnd);
      if (endIndex != -1) {
        result = result.substring(0, endIndex);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
            '$_userName\'s exercise',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
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
            child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: customWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: (_journalEntry != null &&
                  (_journalEntry!.entryMood != 0 ||
                      _journalEntry!.entryImageURL != '' ||
                      _journalEntry!.entryText != '' ||
                      _journalEntry!.entryVoiceNoteURL != ''))
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      image(),
                      Flexible(
                          child: (_emotionsText != '')
                              ? Text(
                                  'I can see that you\'re feeling $_emotionsText today.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: customPurple),
                                )
                              : Text(
                                  'You haven\'t specified any emotions today! Try going back to your journal to personalise the exercise.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: customPurple),
                                )),
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Let\'s try to be more present in the moment with a quick exercise that promotes mindfulness! If you don\'t like it or it doesn\'t work in your environment, generate another one using the button below.',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 400,
                      height: 260,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: customAzure, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isGeneratingExercise
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Text(
                                _exercise,
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 15),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          _generateExercise();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: customYellow,
                            foregroundColor: customPurple),
                        child: const Text(
                          "Generate new",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ))
                  ],
                )
              : Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  image(),
                  Flexible(
                      child: Text(
                    'Complete today\'s journal entry to access the mindfulness exercise!',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),
                  )),
                ]),
        )));
  }

  Widget image() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 60,
          height: 90,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/moon-companion.png'),
                  fit: BoxFit.cover)),
        ));
  }
}
