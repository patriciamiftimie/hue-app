import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hue/services/coloring_page_service.dart';
import 'package:hue/theme/palettes.dart';
import 'package:hue/widgets/coloring_painter.dart';
import '../model/color_palette.dart';
import '../model/coloring_page.dart';
import '../model/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/openai_api_key.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import 'dart:ui' as ui;

final ColoringPageService _coloringPageService = ColoringPageService();
final UserProfileService _userProfileService = UserProfileService();
final JournalService _journalService = JournalService();

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
  final double _strokeWidth = 15.0;
  ColoringPage? _currentPage;
  String? _currentPageId;
  GlobalKey key = GlobalKey();
  bool hasChanged = false;
  JournalEntry? _journalEntry;
  List<dynamic> _ownedPalettes = [];
  ColorPalette activePalette = huePalette;
  final List<ColorPalette> _colorPalettes = colorPalettes;
  bool _isGeneratingPage = false;
  List<dynamic> _emotions = [];
  String _emotionsText = '';
  Image _currentImage = Image.asset('images/phase0.png');

  Future<void> _fetchJournalEntry() async {
    final uid = widget.uid;
    final entry = await _journalService.fetchEntry(uid, _getCurrentDate());

    if (mounted) {
      setState(() {
        _journalEntry = entry.$2;
        if (_journalEntry != null) {
          _emotions = entry.$2!.entryEmotions;
        }
      });
      _generateExercise();
    }
  }

  Future<void> _fetchUser() async {
    final user = await UserProfileService().fetchUser(widget.uid);
    if (mounted) {
      setState(() {
        _ownedPalettes = user!.ownedPalettes;
      });
    }
  }

  Future<void> convertWidgetToImageAndUpload() async {
    if (!hasChanged) {
      return;
    }

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
    _fetchJournalEntry();
    _fetchUser();
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

  Future<void> _generateExercise() async {
    if (mounted) {
      setState(() {
        _isGeneratingPage = true;
      });
    }

    OpenAI.apiKey = OpenAIApiKey.openAIApiKey;

    if (_emotions.isNotEmpty) {
      if (_emotions.length == 1) {
        _emotionsText = _emotions.first.toString();
      } else {
        _emotionsText =
            '${_emotions.sublist(0, _emotions.length - 1).join(', ')} and ${_emotions.last}';
      }
    } else {
      _emotionsText = '';
    }

    final image = await OpenAI.instance.image.create(
        prompt:
            "Create a very simple coloring book page for when i'm feeling $_emotionsText?");

    String? result = image.data.first.url;
    if (mounted) {
      setState(() {
        _currentImage = Image.network(
          result!,
          fit: BoxFit.cover,
        );
        _isGeneratingPage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text(
          'Colouring Book',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: customLilac,
        foregroundColor: customWhite,
        toolbarHeight: MediaQuery.of(context).size.height / 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(1290, 250),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: (_journalEntry != null &&
                  (_journalEntry!.entryMood != 0 ||
                      _journalEntry!.entryImageURL != '' ||
                      _journalEntry!.entryText != '' ||
                      _journalEntry!.entryVoiceNoteURL != ''))
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      image(),
                      Flexible(
                          child: (_emotionsText != '')
                              ? Text(
                                  'Let\'s find something that resonates with how you\'re feeling today. We can generate personalised pages, or you can choose from a set of default templates.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: customWhite),
                                )
                              : Text(
                                  'You haven\'t specified any emotions today! Try going back to your journal for a personalised page.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: customWhite),
                                )),
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _controlButton('Clear', () {
                          setState(() {
                            _coloredPoints.clear();
                            hasChanged = false;
                          });
                        }, customWhite),
                        _controlButton('Undo', () {
                          setState(() {
                            if (_coloredPoints.containsKey(selectedColor) &&
                                _coloredPoints[selectedColor]!.isNotEmpty) {
                              _coloredPoints[selectedColor]!.removeLast();
                            }
                          });
                        }, customWhite),
                        _controlButton(
                            'Generate new',
                            (_currentPage != null)
                                ? null
                                : () {
                                    setState(() {
                                      _generateExercise();
                                      hasChanged = false;
                                    });
                                  },
                            customYellow),
                        _controlButton(
                            'Default templates',
                            (_currentPage != null)
                                ? null
                                : () {
                                    setState(() {
                                      showDefaultTemplates();
                                    });
                                  },
                            customYellow),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RepaintBoundary(
                        key: key,
                        child: Stack(children: [
                          (_currentPage == null)
                              ? Positioned.fill(
                                  child: _isGeneratingPage
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : _currentImage,
                                )
                              : Positioned.fill(
                                  child: Image.network(
                                    _currentPage!.imageURL,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                          FittedBox(
                            child: SizedBox(
                              width: 400,
                              height: 400,
                              child: Opacity(
                                opacity: 0.6,
                                child: GestureDetector(
                                  onPanStart: (details) {
                                    RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    var localPosition = renderBox
                                        .globalToLocal(details.localPosition);
                                    setState(() {
                                      _coloredPoints
                                          .putIfAbsent(selectedColor, () => [])
                                          .add(localPosition);
                                      hasChanged = true;
                                    });
                                  },
                                  onPanUpdate: (details) {
                                    RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    var localPosition = renderBox
                                        .globalToLocal(details.localPosition);
                                    setState(() {
                                      _coloredPoints
                                          .putIfAbsent(selectedColor, () => [])
                                          .add(localPosition);
                                    });
                                  },
                                  onPanEnd: (details) {
                                    setState(() {
                                      _coloredPoints[selectedColor]!
                                          .add(Offset.infinite);
                                    });
                                  },
                                  child: CustomPaint(
                                    painter:
                                        MyPainter(_coloredPoints, _strokeWidth),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ])),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      width: 400,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _colorButton(activePalette.colors[0]),
                          _colorButton(activePalette.colors[1]),
                          _colorButton(activePalette.colors[2]),
                          _colorButton(activePalette.colors[3]),
                          _colorButton(activePalette.colors[4]),
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
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 400,
                    height: 500,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              image(),
                              Flexible(
                                  child: Text(
                                'Complete today\'s journal entry to access the colouring book page!',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: customWhite),
                              )),
                            ]),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          try {
            await convertWidgetToImageAndUpload();

            if (hasChanged) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved', style: TextStyle(fontSize: 18)),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFFA087BC),
                ),
              );
            }
            if (!mounted) return;
            Navigator.pop(context);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save. Please try again.',
                    style: TextStyle(fontSize: 18)),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFFA087BC),
              ),
            );
          }
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
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }

  Widget _controlButton(String label, VoidCallback? onPressed, Color color) {
    return Flexible(
        child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: customPurple),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
      ),
    ));
  }

  Future<void> showDefaultTemplates() async {
    final List<String> templateImages = [
      'images/template1.png',
      'images/template2.png',
      'images/template3.png',
      'images/template4.png',
      'images/template5.png',
      'images/template6.png',
    ];

    final selectedImageUrl = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select a Template',
            style: TextStyle(color: customPurple),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templateImages.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(templateImages[index]),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(templateImages[index]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedImageUrl != null) {
      setState(() {
        _currentImage = Image.asset(
          selectedImageUrl,
          fit: BoxFit.cover,
        );
        hasChanged = false;
      });
    }
  }

  Future<void> showAvailableColourPalettes() async {
    final selectedPalette = await showDialog<ColorPalette>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select a Color Palette',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: customPurple, fontSize: 20),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _ownedPalettes.length,
              itemBuilder: (context, index) {
                final palette = _colorPalettes.firstWhere(
                  (palette) => palette.paletteId == _ownedPalettes[index],
                );

                return ListTile(
                  title: buildColorPalette(palette),
                  onTap: () {
                    Navigator.of(context).pop(palette);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedPalette != null) {
      setState(() {
        activePalette = selectedPalette;
      });
    }
  }

  Widget buildColorPalette(ColorPalette palette) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 179, 179, 179),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            palette.name,
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: customWhite),
          ),
          const SizedBox(height: 10.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (Color color in palette.colors)
              Flexible(
                  child: Container(
                width: 30.0,
                height: 30.0,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              )),
          ])
        ],
      ),
    );
  }

  Future<void> updateCoins(int coins) async {
    final uid = widget.uid;
    await _userProfileService.updateCoins(uid, coins);
  }

  Widget image() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 60,
          height: 90,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/moon-companion.png'),
                  fit: BoxFit.cover)),
        ));
  }
}
