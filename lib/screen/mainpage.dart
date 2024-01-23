import 'package:flutter/material.dart';
import 'package:hue/screen/home.dart';
import 'package:hue/screen/scrapbook.dart';
import 'package:hue/screen/settings.dart';
import 'package:hue/screen/shop.dart';
import 'package:hue/widgets/coin_count.dart';
import '../theme/colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title, required this.uid});

  final String title;
  final String uid;
  @override
  State<MainPage> createState() => _MainPageState();
}

//home screen state
class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ScrapbookScreen(title: 'Scrapbook', uid: widget.uid),
      HomeScreen(title: "Home", uid: widget.uid),
      ShopScreen(title: "Shop", uid: widget.uid),
      SettingsScreen(title: "Settings", uid: widget.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hue',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: customLilac,
        foregroundColor: customWhite,
        toolbarHeight: MediaQuery.of(context).size.height / 7,
        leading: Container(),
        actions: [CoinCount(uid: widget.uid)],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(1290, 250),
          ),
        ),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'Scrapbook'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_rounded), label: 'Shop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
        iconSize: 30,
        selectedFontSize: 15,
        selectedItemColor: customPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
