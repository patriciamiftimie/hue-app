import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';

import '../services/journal_service.dart';

class EmotionsEntry extends StatefulWidget {
  const EmotionsEntry(
      {super.key, required this.uid, required this.onEmotionsUpload});
  final String uid;
  final Function(List<dynamic>) onEmotionsUpload;

  @override
  State<EmotionsEntry> createState() => _EmotionsEntryScale();
}

class _EmotionsEntryScale extends State<EmotionsEntry> {
  final List<dynamic> emotions = [
    'content',
    'thankful',
    'proud',
    'loved',
    'hopeful',
    'energetic',
    'happy',
    'excited',
    'relaxed',
    'meh',
    'detached',
    'pressured',
    'angry',
    'worried',
    'sad',
    'tired',
    'guilty',
    'anxious',
    'ashamed',
    'nervous',
    'hurt',
    'overwhelmed',
    'lonely',
    'scared',
    'annoyed'
  ];

  List<dynamic> selectedEmotions = [];

  void _toggleEmotion(String emotion) {
    setState(() {
      if (selectedEmotions.contains(emotion)) {
        selectedEmotions.remove(emotion);
      } else {
        selectedEmotions.add(emotion);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserEmotions();
  }

  Future<void> _fetchUserEmotions() async {
    final userEmotions = await JournalService().fetchUserEmotions(widget.uid);
    setState(() {
      selectedEmotions = userEmotions ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: customWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              'What emotions best describe you today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: emotions
                    .map((emotion) => GestureDetector(
                          onTap: () => _toggleEmotion(emotion),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: selectedEmotions.contains(emotion)
                                  ? customAzure
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              emotion,
                              style: TextStyle(
                                  color: selectedEmotions.contains(emotion)
                                      ? customWhite
                                      : Colors.grey[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  widget.onEmotionsUpload(selectedEmotions);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: customYellow,
                    foregroundColor: customPurple),
                child: const Text("Save selected"))
          ],
        ));
  }
}
