import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hue/model/user.dart' as user_model;

class UserProfileService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(
    User user,
    String name,
  ) {
    return usersCollection.doc(user.uid).set({
      'email': user.email,
      'name': name,
      'coins': 0,
      'owned_palettes': ['hue000'],
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data()!;
      } else {
        return {};
      }
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      return {};
    }
  }

  Future<String?> fetchUserName(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();

    if (snapshot.exists) {
      user_model.User user = user_model.User.fromMap(snapshot.data()!);
      return user.name;
    } else {
      return null;
    }
  }

  Future<int?> fetchUserCoins(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();

    if (snapshot.exists) {
      user_model.User user = user_model.User.fromMap(snapshot.data()!);
      return user.coins;
    } else {
      return null;
    }
  }

  Future<user_model.User?> fetchUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();

    if (snapshot.exists) {
      user_model.User user = user_model.User.fromMap(snapshot.data()!);
      return user;
    } else {
      return null;
    }
  }

  Future<void> updateUser(String uid, user_model.User user) async {
    await usersCollection.doc(uid).update(user.toMap());
  }

  Future<void> addToOwnedPalettes(String userId, String paletteId) async {
    final userDocRef = usersCollection.doc(userId);

    await userDocRef.update({
      'owned_palettes': FieldValue.arrayUnion([paletteId]),
    });
  }

  Future<void> updateCoins(String uid, int amount) async {
    final user = await fetchUser(uid);
    if (user != null) {
      final updatedUser = user_model.User(
          name: user.name,
          email: user.email,
          coins: user.coins + amount,
          ownedPalettes: user.ownedPalettes,
          created: user.created);
      await usersCollection.doc(uid).update(updatedUser.toMap());
    }
  }
}
