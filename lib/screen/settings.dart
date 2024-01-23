import 'package:flutter/material.dart';
import 'package:hue/auth/auth.dart';
import 'package:hue/model/user.dart';
import 'package:hue/services/user_profile_service.dart';
import 'package:hue/theme/colors.dart';

final UserProfileService _userProfileService = UserProfileService();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.title, required this.uid});

  final String title;
  final String uid;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  String _userName = "";

  // Function to show the name edit dialog
  Future<void> _showEditNameDialog() async {
    TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
                hintText: 'What would you like to be called?'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                updateName(nameController.text);
                setState(() {
                  _userName = nameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await UserProfileService().fetchUser(widget.uid);
    if (mounted) {
      setState(() {
        _user = user;
        _userName = user!.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                'Name',
                style: TextStyle(color: Colors.grey[800], fontSize: 18),
              ),
              subtitle: Text(
                _userName,
                style: TextStyle(color: Colors.grey[800], fontSize: 16),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 30,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  _showEditNameDialog();
                },
              ),
            ),
            const Divider(),
            Text(
              'Notification Settings',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              selectedColor: customYellow,
              title: Text(
                'Push Notifications',
                style: TextStyle(color: Colors.grey[800], fontSize: 18),
              ),
              trailing: Switch(
                trackColor: trackColor,
                value:
                    true, // TODO Replace with actual notification setting value
                onChanged: (value) {
                  // Handle the toggle event
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                signOutUser();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff735DA5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 55)),
              child: const Text(
                'Log out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateName(String name) async {
    final uid = widget.uid;
    final updatedUser = User(
        name: name,
        email: _user!.email,
        coins: _user!.coins,
        created: _user!.created);
    await _userProfileService.updateUser(uid, updatedUser);
    // Fetch the updated entry
    await _fetchUser();
  }

  final MaterialStateProperty<Color?> trackColor =
      MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return customYellow;
      }
      return null;
    },
  );
}
