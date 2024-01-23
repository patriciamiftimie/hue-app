import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String email;
  int coins;
  Timestamp created;

  User(
      {required this.name,
      required this.email,
      required this.coins,
      required this.created});

  // Factory method to convert a Map to a JournalEntry object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      coins: map['coins'],
      created: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'coins': coins,
      'created_at': created
    };
  }
}
