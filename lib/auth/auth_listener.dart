import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../firebase_setup.dart';

void setupAuthListener() {
  setupFirebase(); // Call the Firebase setup function

  // Listen for changes in auth state
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      if (kDebugMode) {
        print('User is currently signed out!');
      }
      // Add any actions you want to perform when the user signs out
    } else {
      if (kDebugMode) {
        print('User is signed in!');
      }
      // Add any actions you want to perform when the user signs in
    }
  });

// Listen for changes in the user's ID token
  FirebaseAuth.instance.idTokenChanges().listen((User? user) {
    if (user == null) {
      if (kDebugMode) {
        print('User is currently signed out!');
      }
      // Add any actions you want to perform when the user signs out
    } else {
      if (kDebugMode) {
        print('User is signed in!');
      }
      // Add any actions you want to perform when the user signs in
    }
  });

// Listen for changes in the entire user object
  FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null) {
      if (kDebugMode) {
        print('User is currently signed out!');
      }
      // Add any actions you want to perform when the user signs out
    } else {
      if (kDebugMode) {
        print('User is signed in!');
      }
      // Add any actions you want to perform when the user signs in
    }
  });
}
