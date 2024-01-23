import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.title, required this.uid});

  final String title;
  final String uid;
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('shop'),
    );
  }
}
