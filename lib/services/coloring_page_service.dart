import 'package:cloud_firestore/cloud_firestore.dart';
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
      print('Error fetching user image: $e');
      return null;
    }
  }

  // Future<void> createColoringPage(ColoringPage data, String uid) async {
  //   try {
  //     final docRef = await FirebaseFirestore.instance
  //         .collection('coloringBookPages')
  //         .doc(uid)
  //         .collection(_getDate());

  //     docRef.add({
  //       'coloredPoints': data.coloredPoints,
  //       'strokeWidth': data.strokeWidth,
  //       'timestamp': data.timestamp
  //     });
  //   } catch (e) {
  //     print('error creating page in service: $e');
  //   }
  // }

  // Future<void> updateColoringPage(ColoringPage data, String uid, String dataId,
  //     Map<String, dynamic> coloredPoints) async {
  //   try {
  //     final docRef = FirebaseFirestore.instance
  //         .collection('coloringBookPages')
  //         .doc(uid)
  //         .collection(_getDate())
  //         .doc(dataId);

  //     docRef.set({
  //       'coloredPoints': coloredPoints,
  //       'strokeWidth': data.strokeWidth,
  //       'timestamp': data.timestamp
  //     });
  //   } catch (e) {
  //     print('error in update service: $e');
  //   }
  // }

  // Future<(String?, ColoringPage?)> fetchColoringPage(
  //     String uid, String date) async {
  //   final snapshot =
  //       await coloringBookCollection.doc(uid).collection(date).get();

  //   if (snapshot.docs.isNotEmpty) {
  //     final entryMap = snapshot.docs.first.data();
  //     return (snapshot.docs.first.id, ColoringPage.fromMap(entryMap));
  //   } else {
  //     return (null, null);
  //   }
  // }

  // Future<void> saveColoringPage(ColoringPage coloringPage, String uid) async {
  //   try {
  //     final docRef = await FirebaseFirestore.instance
  //         .collection('coloringBookPages')
  //         .doc(uid)
  //         .collection(_getDate())
  //         .doc('g3wtZgqoUERbbLqB4GOS');
  //     var serializedPoints =
  //         _serializeColoredPoints(coloringPage.coloredPoints);

  //     docRef.update({
  //       'coloredPoints': serializedPoints,
  //       'strokeWidth': coloringPage.strokeWidth,
  //       'timestamp': coloringPage.timestamp
  //     });
  //   } catch (e) {
  //     print('error creating page in service: $e');
  //   }
  // }

  // ColoringPage _deserializeColoringPage(Map<String, dynamic> data) {
  //   final Map<String, dynamic> coloredPointsData = data['coloredPoints'];
  //   final coloredPoints = coloredPointsData.map(
  //     (key, value) => MapEntry(
  //       _deserializeColor(key),
  //       (value as List<dynamic>).map((point) {
  //         final List<dynamic> coordinates = point;
  //         return Offset(coordinates[0] as double, coordinates[1] as double);
  //       }).toList(),
  //     ),
  //   );

  //   return ColoringPage(
  //       coloredPoints: coloredPoints,
  //       strokeWidth: data['strokeWidth'] as double,
  //       timestamp: data['timestamp']);
  // }

  // Map<String, List<(double, double)>> _serializeColoredPoints(
  //   Map<Color, List<Offset>> coloredPoints,
  // ) {
  //   return coloredPoints.map(
  //     (key, value) => MapEntry(
  //       _serializeColor(key),
  //       value.map((offset) => (offset.dx, offset.dy)).toList(),
  //     ),
  //   );
  // }

  // Color _deserializeColor(String color) {
  //   return Color(int.parse(color));
  // }

  // String _serializeColor(Color color) {
  //   return "Red";
  // }

  String _getDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }
}
