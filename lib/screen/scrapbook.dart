import 'package:flutter/material.dart';
import 'package:hue/screen/scrapbook_page.dart';
import 'package:hue/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/journal_service.dart';

class ScrapbookScreen extends StatefulWidget {
  const ScrapbookScreen({super.key, required this.title, required this.uid});

  final String title;
  final String uid;
  @override
  State<ScrapbookScreen> createState() => _ScrapbookScreenState();
}

class _ScrapbookScreenState extends State<ScrapbookScreen> {
  Map<String, int> _moodData = {};
  DateTime _focusedDay = DateTime.now();

  String _getDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _fetchMoodData(DateTime.now().year, DateTime.now().month);
  }

  Future<void> _fetchMoodData(int year, int month) async {
    final moodsMonth =
        await JournalService().fetchMoodsForMonth(widget.uid, year, month);
    if (mounted) {
      setState(() {
        _moodData = moodsMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(20), child: _buildCalendar()),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      daysOfWeekHeight: 20,
      headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: customPurple, fontSize: 18)),
      shouldFillViewport: true,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      focusedDay: _focusedDay,
      firstDay: DateTime(2017, 9, 7, 17, 30),
      lastDay: DateTime(2027, 9, 7, 17, 30),
      onPageChanged: (DateTime focusedDay) async {
        _focusedDay = focusedDay;
        await _fetchMoodData(_focusedDay.year, _focusedDay.month);
      },
      calendarBuilders: CalendarBuilders(
        todayBuilder: (context, date, _) =>
            _buildDayContainer(date, isToday: true),
        defaultBuilder: (context, date, _) => _buildDayContainer(date),
      ),
    );
  }

  Widget _buildDayContainer(DateTime date, {bool isToday = false}) {
    int mood = _moodData[_getDate(date)] ?? 0; // Default mood if not found

    return Container(
      decoration: const BoxDecoration(shape: BoxShape.rectangle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (mood == 0) {
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScrapbookPage(
                      date: _getDate(date),
                      uid: widget.uid,
                    ),
                  ),
                );
              }
            },
            child: Image.asset(
              'images/phase$mood.png',
              fit: BoxFit.cover,
              height: 60, // Adjust the height as needed
            ),
          ),
        ],
      ),
    );
  }

  Widget image(int mood) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: double.infinity,
          height: 30,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/phase$mood.png'),
                  fit: BoxFit.cover)),
        ));
  }
}
