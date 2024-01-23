import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/journal_entry.dart';

class JournalService {
  final CollectionReference journalCollection =
      FirebaseFirestore.instance.collection('journalEntries');

  Future<void> createEntry(JournalEntry entry, String uid) async {
    await journalCollection.doc(uid).collection(_getDate()).add(entry.toMap());
  }

  Future<void> updateEntry(
      JournalEntry entry, String uid, String entryId) async {
    await journalCollection
        .doc(uid)
        .collection(_getDate())
        .doc(entryId)
        .update(entry.toMap());
  }

  Future<(String?, JournalEntry?)> fetchEntry(String uid, String date) async {
    final snapshot = await journalCollection.doc(uid).collection(date).get();

    if (snapshot.docs.isNotEmpty) {
      final entryMap = snapshot.docs.first.data();
      return (snapshot.docs.first.id, JournalEntry.fromMap(entryMap));
    } else {
      return (null, null);
    }
  }

  Future<int?> fetchUserMood(String uid) async {
    try {
      final snapshot =
          await journalCollection.doc(uid).collection(_getDate()).get();
      if (snapshot.docs.isNotEmpty) {
        JournalEntry entry = JournalEntry.fromMap(snapshot.docs.first.data());
        return entry.entryMood;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user mood: $e');
      return null;
    }
  }

  Future<int> fetchUserMoodDay(String uid, DateTime date) async {
    try {
      String formattedDate = '${date.day}-${date.month}-${date.year}';
      final snapshot =
          await journalCollection.doc(uid).collection(formattedDate).get();
      if (snapshot.docs.isNotEmpty) {
        JournalEntry entry = JournalEntry.fromMap(snapshot.docs.first.data());
        return entry.entryMood;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching user mood: $e');
      return 0;
    }
  }

  Future<Map<String, JournalEntry?>> fetchEntriesForMonth(
      String uid, int year, int month) async {
    try {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      DateTime lastDayOfMonth =
          DateTime(year, month + 1, 1).subtract(const Duration(days: 1));

      int firstDay = firstDayOfMonth.day;
      int lastDay = lastDayOfMonth.day;

      Map<String, JournalEntry?> entriesMap = {};

      for (int i = firstDay; i <= lastDay; i++) {
        String date = '$i-$month-$year';
        final entry = await fetchEntry(uid, date);
        entriesMap[date] = entry.$2;
      }

      return entriesMap;
    } catch (e) {
      print('Error fetching entries for month: $e');
      return {};
    }
  }

  Future<Map<String, int>> fetchMoodsForMonth(
      String uid, int year, int month) async {
    try {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      DateTime lastDayOfMonth =
          DateTime(year, month + 1, 1).subtract(const Duration(days: 1));

      int firstDay = firstDayOfMonth.day;
      int lastDay = lastDayOfMonth.day;

      List<Future<int>> fetchEntryTasks = [];

      for (int i = firstDay; i <= lastDay; i++) {
        String date = '$i-$month-$year';
        fetchEntryTasks.add(
            fetchEntry(uid, date).then((entry) => entry.$2?.entryMood ?? 0));
      }

      List<int> results = await Future.wait(fetchEntryTasks);

      Map<String, int> entriesMap = {};
      for (int i = firstDay; i <= lastDay; i++) {
        String date = '$i-$month-$year';
        entriesMap[date] = results[i - firstDay];
      }

      return entriesMap;
    } catch (e) {
      print('Error fetching entries for month: $e');
      return {};
    }
  }

  Future<String?> fetchUserImageURL(String uid) async {
    try {
      final snapshot =
          await journalCollection.doc(uid).collection(_getDate()).get();
      if (snapshot.docs.isNotEmpty) {
        JournalEntry entry = JournalEntry.fromMap(snapshot.docs.first.data());
        return entry.entryImageURL;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user image: $e');
      return null;
    }
  }

  Future<String?> fetchUserText(String uid) async {
    try {
      final snapshot =
          await journalCollection.doc(uid).collection(_getDate()).get();
      if (snapshot.docs.isNotEmpty) {
        JournalEntry entry = JournalEntry.fromMap(snapshot.docs.first.data());
        return entry.entryText;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user text: $e');
      return null;
    }
  }

  Future<String?> fetchUserVoiceNoteURL(String uid) async {
    try {
      final snapshot =
          await journalCollection.doc(uid).collection(_getDate()).get();
      if (snapshot.docs.isNotEmpty) {
        JournalEntry entry = JournalEntry.fromMap(snapshot.docs.first.data());
        return entry.entryVoiceNoteURL;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user voice note: $e');
      return null;
    }
  }

  String _getDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }
}
