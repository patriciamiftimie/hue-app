import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> createUserDocument(User user, String name) async {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  return users.doc(user.uid).set({
    'name': name,
    'email': user.email,
    'coins': 0,
    'owned_palettes': ['hue000'],
    'created_at': FieldValue.serverTimestamp(),
  });
}

Future<bool> registerUser(String email, String password, String name) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create Firestore user document
    await createUserDocument(userCredential.user!, name);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> signInUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (kDebugMode) {
      print('User signed in successfully!');
    }
    return true;
  } catch (e) {
    if (kDebugMode) {
      print('Error signing in: $e');
    }
    return false;
  }
}

Future<void> signOutUser() async {
  await FirebaseAuth.instance.signOut();
  if (kDebugMode) {
    print('User signed out successfully!');
  }
}
