import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';
import 'package:image_picker/image_picker.dart';

import '../services/journal_service.dart';

class GratitudeEntry extends StatefulWidget {
  const GratitudeEntry(
      {super.key, required this.uid, required this.onImageUpload});
  final String uid;
  final Function(String) onImageUpload;

  @override
  State<GratitudeEntry> createState() => _GratitudeEntryState();
}

class _GratitudeEntryState extends State<GratitudeEntry> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  String _getDate() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  Future<void> _fetchUserImageURL() async {
    final userImageURL = await JournalService().fetchUserImageURL(widget.uid);
    setState(() {
      _imageUrl = userImageURL;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? imageFile = await _picker.pickImage(source: source);

    if (imageFile != null) {
      String? imageUrl = await uploadImageToStorage(
          File(imageFile.path), widget.uid, _getDate());
      if (mounted) {
        setState(() {
          _imageUrl = imageUrl;
        });
      }
      widget.onImageUpload(_imageUrl!);
    }
  }

  Future<String?> uploadImageToStorage(
      File imageFile, String uid, String date) async {
    try {
      String fileName =
          '$date.jpg'; // Constructing a unique file name based on the date
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('$uid/gratitude_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() {});

      // Get the download URL after the upload is complete
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserImageURL();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What is something you\'re grateful for?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: customPurple),
          ),
          const SizedBox(height: 16),
          (_imageUrl == null || _imageUrl == "")
              ? const Placeholder(
                  fallbackHeight: 200.0,
                  fallbackWidth: double.infinity,
                  strokeWidth: 0,
                  color: Color.fromARGB(255, 201, 201, 201),
                  child: Icon(Icons.add_a_photo_rounded,
                      color: Color.fromARGB(255, 201, 201, 201), size: 100),
                )
              : Image.network(
                  _imageUrl!,
                  height: 200.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: customYellow,
                        foregroundColor: customPurple),
                    child: const Text(
                      "Choose from gallery",
                      textAlign: TextAlign.center,
                    )),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customYellow,
                      foregroundColor: customPurple),
                  child: const Text(
                    "Take a picture",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
