import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';

class CoinCount extends StatefulWidget {
  const CoinCount({super.key, required this.uid});
  final String uid;

  @override
  State<CoinCount> createState() => _CoinCountState();
}

class _CoinCountState extends State<CoinCount> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final coinBalance = userData['coins'] ?? 0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            width: 70,
            height: 25,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Icon(
                  Icons.circle,
                  color: customYellow,
                ),
                Text(
                  ' $coinBalance',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
        });
  }
}
