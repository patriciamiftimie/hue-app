import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<String> loadAsset() async {
    return await rootBundle.loadString('images/privacy_policy.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 30),
          ),
          backgroundColor: customLilac,
          foregroundColor: customWhite,
          toolbarHeight: MediaQuery.of(context).size.height / 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(1290, 250),
            ),
          )),
      body: FutureBuilder(
        future: loadAsset(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Text(snapshot.data ?? ''),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
