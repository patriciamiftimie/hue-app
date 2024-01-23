import 'package:flutter/material.dart';
import 'package:hue/theme/colors.dart';

import '../services/user_profile_service.dart';

class CoinCount extends StatefulWidget {
  const CoinCount({super.key, required this.uid});
  final String uid;

  @override
  State<CoinCount> createState() => _CoinCountState();
}

class _CoinCountState extends State<CoinCount> {
  int _coins = 0; // Default rating

  @override
  void initState() {
    super.initState();
    _fetchUserCoins();
  }

  Future<void> _fetchUserCoins() async {
    final coins = await UserProfileService().fetchUserCoins(widget.uid);
    setState(() {
      _coins = coins ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      width: 60,
      height: 25,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Icon(
            Icons.circle,
            color: customYellow,
          ),
          Text(
            ' $_coins',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
