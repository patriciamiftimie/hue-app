import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hue/services/coloring_page_service.dart';
import 'package:hue/widgets/coloring_painter.dart';
import '../model/coloring_page.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import 'dart:ui' as ui;

final ColoringPageService _coloringPageService = ColoringPageService();
final UserProfileService _userProfileService = UserProfileService();

class ColoringBookPage extends StatefulWidget {
  const ColoringBookPage({super.key, required this.title, required this.uid});

  final String title;
  final String uid;

  @override
  State<ColoringBookPage> createState() => _ColoringBookPageState();
}

class _ColoringBookPageState extends State<ColoringBookPage> {
  final Map<Color, List<Offset>> _coloredPoints = {};
  Color selectedColor = Colors.white;
  final double _strokeWidth = 5.0;
  ColoringPage? _currentPage;
  String? _currentPageId;
  GlobalKey key = GlobalKey();

  void convertWidgetToImageAndUpload() async {
    final uid = widget.uid;
    String date = _getCurrentDate();
    String fileName = '$date.jpg';
    RenderRepaintBoundary renderRepaintBoundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 1);
    ByteData? byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      Uint8List uint8list = byteData.buffer.asUint8List();
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('$uid/coloring_book_pages/$fileName.png');
      UploadTask uploadTask = storageReference.putData(uint8list);

      await uploadTask.whenComplete(() {});

      String imageUrl = await storageReference.getDownloadURL();

      if (_currentPage != null) {
        _currentPage!.imageURL = imageUrl;
        await _coloringPageService.updatePage(
            _currentPage!, uid, _currentPageId!);
      } else {
        final newPage = ColoringPage(
          imageURL: imageUrl,
          timestamp: Timestamp.now(),
        );
        await _coloringPageService.createPage(newPage, uid);
        updateCoins(5);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchColoringPage();
  }

  Future<void> _fetchColoringPage() async {
    final page =
        await _coloringPageService.fetchPage(widget.uid, _getCurrentDate());

    if (mounted) {
      setState(() {
        _currentPageId = page.$1;
        _currentPage = page.$2;
      });
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text(
          'Mindful Colouring Book',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: customLilac,
        foregroundColor: customWhite,
        toolbarHeight: MediaQuery.of(context).size.height / 7,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(1290, 250),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton('Clear', () {
                  setState(() {
                    _coloredPoints.clear();
                  });
                }),
                _controlButton('Undo', () {
                  setState(() {
                    if (_coloredPoints.containsKey(selectedColor) &&
                        _coloredPoints[selectedColor]!.isNotEmpty) {
                      _coloredPoints[selectedColor]!.removeLast();
                    }
                  });
                }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            RepaintBoundary(
                key: key,
                child: Stack(children: [
                  (_currentPage == null)
                      ? Positioned.fill(
                          child: Image.asset(
                            'images/coloring1.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Positioned.fill(
                          child: Image.network(
                            _currentPage!.imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                  FittedBox(
                    child: SizedBox(
                      width: 400,
                      height: 500,
                      child: GestureDetector(
                        onPanStart: (details) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          var localPosition =
                              renderBox.globalToLocal(details.localPosition);
                          setState(() {
                            _coloredPoints
                                .putIfAbsent(selectedColor, () => [])
                                .add(localPosition);
                          });
                        },
                        onPanUpdate: (details) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          var localPosition =
                              renderBox.globalToLocal(details.localPosition);
                          setState(() {
                            _coloredPoints
                                .putIfAbsent(selectedColor, () => [])
                                .add(localPosition);
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _coloredPoints[selectedColor]!.add(Offset.infinite);
                          });
                        },
                        child: CustomPaint(
                          painter: MyPainter(_coloredPoints, _strokeWidth),
                        ),
                      ),
                    ),
                  ),
                ])),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 40,
              width: 400,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _colorButton(customPurple),
                  _colorButton(customAzure),
                  _colorButton(customYellow),
                  _colorButton(customLilac),
                  _colorButton(customWhite),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: customWhite,
                      size: 30,
                    ),
                    onPressed: () {
                      showAvailableColourPalettes();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          convertWidgetToImageAndUpload();
          Navigator.pop(context);
        },
        heroTag: 'saveColouringPage',
        backgroundColor: const Color(0xff735DA5),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Text(
          'Done',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Widget _colorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _controlButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: customYellow, foregroundColor: customPurple),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> showAvailableColourPalettes() async {
    return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog();
        });
  }

  Future<void> updateCoins(int coins) async {
    final uid = widget.uid;
    await _userProfileService.updateCoins(uid, coins);
  }

  // Future<void> _saveOrUpdateData() async {
  //   final uid = widget.uid;
  //   final serializedColoredPoints = _serializeColoredPoints(_coloredPoints);

  //   if (_currentPage != null) {
  //     // _currentPage!.coloredPoints =
  //     //     serializedColoredPoints.cast<Color, List<Offset>>();
  //     print('updating');
  //     print(serializedColoredPoints);
  //     try {
  //       await _coloringPageService.saveColoringPage(_currentPage!, uid);
  //     } catch (e) {
  //       print('error updating: $e');
  //     }
  //   } else {
  //     print('creating');
  //     final newPage = ColoringPage(
  //       coloredPoints: _coloredPoints,
  //       strokeWidth: _strokeWidth,
  //       timestamp: Timestamp.now(),
  //     );
  //     await _coloringPageService.createColoringPage(newPage, uid);
  //     updateCoins(5);
  //     ;
  //   }
  // }

  // Map<String, dynamic> _serializeColoredPoints(
  //   Map<Color, List<Offset>> coloredPoints,
  // ) {
  //   final serializedColoredPoints = <String, dynamic>{};

  //   coloredPoints.forEach((color, points) {
  //     final serializedPoints = points.map((offset) {
  //       return [offset.dx, offset.dy];
  //     }).toList();

  //     serializedColoredPoints[_serializeColor(color)] = serializedPoints;
  //   });

  //   return serializedColoredPoints;
  // }

  // String _serializeColor(Color color) {
  //   return "0xFF${color.value}";
  // }
}
