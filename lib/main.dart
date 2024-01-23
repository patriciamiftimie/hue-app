import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as firebase_options;
import 'auth/auth_listener.dart';
import 'screen/mainpage.dart';
import 'screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebase_options.DefaultFirebaseOptions.currentPlatform,
  );
  setupAuthListener(); // Call the auth listener setup
  runApp(const MyApp());
}

//whole app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while checking authentication state
          } else {
            if (snapshot.hasData) {
              return MainPage(
                title: 'Hue Home Page',
                uid: FirebaseAuth.instance.currentUser!.uid,
              ); // Navigate to home screen if user is signed in
            } else {
              return const LoginScreen(); // Show login screen if user is signed out
            }
          }
        },
      ),
    );
  }
}
