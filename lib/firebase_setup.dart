import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp();

  // Use setPersistence() instead of persistence
  final auth = FirebaseAuth.instanceFor(app: Firebase.app());
  await auth.setPersistence(Persistence.LOCAL);
}
