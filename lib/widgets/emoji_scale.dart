import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';

import '../services/journal_service.dart';

class EmojiScale extends StatefulWidget {
  const EmojiScale(
      {super.key, required this.uid, required this.onRatingUpload});
  final String uid;
  final Function(int) onRatingUpload;

  @override
  State<EmojiScale> createState() => _EmojiScaleState();
}

class _EmojiScaleState extends State<EmojiScale> {
  int selectedRating = 0; // Default rating

  @override
  void initState() {
    super.initState();
    _fetchUserMood();
  }

  Future<void> _fetchUserMood() async {
    final userMood = await JournalService().fetchUserMood(widget.uid);
    setState(() {
      selectedRating = userMood ?? 0;
    });
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
          children: [
            Text(
              'How are you feeling today?*',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: customPurple),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                    widget.onRatingUpload(selectedRating);
                  },
                  child: Icon(
                    index < selectedRating
                        ? Icons.circle
                        : Icons.circle_outlined, //change when companion
                    size: 40,
                    color: customYellow,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
