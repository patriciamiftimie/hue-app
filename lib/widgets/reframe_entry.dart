import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';
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
            'How can you turn these thoughts into more helpful ones?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
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
                  backgroundColor: customYellow, foregroundColor: customPurple),
              child: const Text("Save"))
        ],
      ),
    );
  }
}
