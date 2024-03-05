import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hue/model/coloring_page.dart';

class ColoringPageService {
  final CollectionReference coloringBookCollection =
      FirebaseFirestore.instance.collection('coloringBookPages');

  Future<void> createPage(ColoringPage page, String uid) async {
    await coloringBookCollection
        .doc(uid)
        .collection(_getDate())
        .add(page.toMap());
  }

  Future<void> updatePage(ColoringPage page, String uid, String pageId) async {
    await coloringBookCollection
        .doc(uid)
        .collection(_getDate())
        .doc(pageId)
        .update(page.toMap());
  }

  Future<(String?, ColoringPage?)> fetchPage(String uid, String date) async {
    final snapshot =
        await coloringBookCollection.doc(uid).collection(date).get();

    if (snapshot.docs.isNotEmpty) {
      final entryMap = snapshot.docs.first.data();
      return (snapshot.docs.first.id, ColoringPage.fromMap(entryMap));
    } else {
      return (null, null);
    }
  }

  Future<String?> fetchImageUrlByDate(String uid, String date) async {
    try {
      final snapshot =
          await coloringBookCollection.doc(uid).collection(date).get();
      if (snapshot.docs.isNotEmpty) {
        ColoringPage entry = ColoringPage.fromMap(snapshot.docs.first.data());
        return entry.imageURL;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user image: $e');
      }
      return null;
    }
  }

  String _getDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }
}
