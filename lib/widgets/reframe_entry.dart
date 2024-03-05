import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/journal_service.dart';

class ReframeEntry extends StatefulWidget {
  const ReframeEntry(
      {super.key, required this.uid, required this.onTextUpload});
  final String uid;
  final Function(String) onTextUpload;

  @override
  State<ReframeEntry> createState() => _ReframeEntryState();
}

class _ReframeEntryState extends State<ReframeEntry> {
  TextEditingController textController = TextEditingController();

  Future<void> _fetchUserText() async {
    final userText = await JournalService().fetchUserText(widget.uid);
    setState(() {
      textController.text = userText ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserText();
  }

  void _showSupportMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Need some help?'),
          content: const Text(
              'If you talked about something that worries you in the section above, you might find the NHS "Thought record" template useful for this section. Otherwise, use it as a regular journal for today.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Visit NHS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                launchUrl(Uri.parse(
                    'https://www.nhs.uk/every-mind-matters/mental-wellbeing-tips/self-help-cbt-techniques/thought-record/'));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                'How can you turn these thoughts into more helpful ones?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: customPurple),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: textController,
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    widget.onTextUpload(textController.text);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customYellow,
                      foregroundColor: customPurple),
                  child: const Text("Save text"))
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
            child: FloatingActionButton(
              mini: true,
              onPressed: _showSupportMessage,
              backgroundColor: customAzure,
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: customWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
