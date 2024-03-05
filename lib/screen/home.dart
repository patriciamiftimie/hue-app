import 'package:flutter/material.dart';
import 'package:hue/screen/mindfulness.dart';
import 'package:hue/theme/colors.dart';
import '../services/user_profile_service.dart';
import '../widgets/typewriter.dart';
import 'journal.dart';
import 'coloring_book.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, required this.uid});

  final String title;
  final String uid;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool completedJournal = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Positioned(child: image()),
                  Positioned(
                    right: 0,
                    bottom: 16,
                    child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: welcomeName()),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisSize: MainAxisSize.max, children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JournalPage(
                          title: 'Journal',
                          uid: widget.uid,
                        ),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  backgroundColor: customPurple,
                  fixedSize: Size(screenWidth - 32, 120),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Journal',
                  style: TextStyle(
                      color: customWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Flexible(
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: completedJournal
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MindfulnessPage(
                                        title: 'Mindfulness Exercise',
                                        uid: widget.uid),
                                  ));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: customAzure,
                        elevation: 3,
                        fixedSize: Size(screenWidth / 2.2, 150),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Mindfulness exercise',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: completedJournal
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ColoringBookPage(
                                        title: 'Coloring book',
                                        uid: widget.uid),
                                  ));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: customLilac,
                        elevation: 3,
                        fixedSize: Size(screenWidth / 2.2, 150),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Colouring book',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ])),
          ],
        ),
      ),
    );
  }

  FutureBuilder<Map<String, dynamic>> welcomeName() {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserProfileService().getUserProfile(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          String userName = snapshot.data?['name'] ?? 'unknown';
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.53,
              child: TypewriterText(
                'Hi, $userName! Today\'s journal entry unlocks a personalised mindfulness exercise and a new page of the stress relief colouring book.',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                align: TextAlign.center, // For better appearance
              ),
            ),
          );
        }
      },
    );
  }

  Widget image() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 120,
          height: 200,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/moon-companion.png'),
                  fit: BoxFit.cover)),
        ));
  }
}
