import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String email;
  int coins;
  List<dynamic> ownedPalettes;
  Timestamp created;

  User(
      {required this.name,
      required this.email,
      required this.coins,
      required this.ownedPalettes,
      required this.created});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      coins: map['coins'],
      ownedPalettes: map['owned_palettes'],
      created: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'coins': coins,
      'owned_palettes': ownedPalettes,
      'created_at': created
    };
  }
}
