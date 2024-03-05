import 'package:flutter/material.dart';

import '../model/color_palette.dart';
import '../model/sticker.dart';
import '../services/user_profile_service.dart';
import '../theme/colors.dart';
import '../theme/palettes.dart';
import '../theme/stickers.dart';

final UserProfileService _userProfileService = UserProfileService();

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.title, required this.uid});

  final String title;
  final String uid;
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<ColorPalette> _colorPalettes = colorPalettes;
  List<Sticker> stickersList = stickers;
  List<dynamic> _ownedPalettes = [];
  int _userCoins = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await UserProfileService().fetchUser(widget.uid);
    if (mounted) {
      setState(() {
        _ownedPalettes = user!.ownedPalettes;
        _userCoins = user.coins;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Colour Palettes',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: customPurple,
          ),
        ),
      ),
      Expanded(
          child: ListView.builder(
        itemCount: _colorPalettes.length,
        itemBuilder: (context, index) {
          final palette = _colorPalettes[index];
          final isOwned = _ownedPalettes
              .any((ownedPalette) => ownedPalette == palette.paletteId);

          return buildColorPalette(palette, isOwned);
        },
      ))
    ]));
  }

  Widget buildColorPalette(ColorPalette palette, isOwned) {
    final canPurchase = _userCoins >= palette.price;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 179, 179, 179),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                palette.name,
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: customWhite),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 20,
                      color: customYellow,
                    ),
                    Text(
                      ' ${palette.price}',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: customWhite),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (Color color in palette.colors)
                  Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: canPurchase
                  ? isOwned
                      ? null
                      : () => purchaseColorPalette(palette)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: customWhite,
                foregroundColor: customPurple,
              ),
              child: Text(
                isOwned
                    ? 'Owned'
                    : canPurchase
                        ? 'Buy'
                        : 'Not\nenough',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Future<void> purchaseColorPalette(ColorPalette palette) async {
    await _userProfileService.addToOwnedPalettes(widget.uid, palette.paletteId);
    updateCoins(-palette.price);

    setState(() {
      _fetchUser();
    });
  }

  Future<void> updateCoins(int coins) async {
    final uid = widget.uid;
    await _userProfileService.updateCoins(uid, coins);
  }
}
