import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';
import '../services/user_profile_service.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                image(),
                Positioned(
                  right: 80,
                  bottom: 100,
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: welcomeName()),
                ),
              ],
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          JournalPage(title: 'Journal', uid: widget.uid),
                    ));
              },
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                backgroundColor: customAzure,
                elevation: 3,
                minimumSize: const Size.fromHeight(100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Interactive journal',
                style: TextStyle(
                    color: customWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ColoringBookPage(
                          title: 'Coloring book', uid: widget.uid),
                    ));
              },
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                backgroundColor: customLilac,
                elevation: 3,
                minimumSize: const Size.fromHeight(100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Mindful colouring',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
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
          // User profile retrieved successfully
          String userName = snapshot.data?['name'] ?? 'unknown';
          return Center(
            child: Text(
              'Hi, $userName!',
              style: const TextStyle(fontSize: 18),
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
          width: 400,
          height: 300,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/phase2.png'), fit: BoxFit.cover)),
        ));
  }
}
