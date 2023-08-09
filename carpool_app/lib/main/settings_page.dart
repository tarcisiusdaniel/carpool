import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // This widget is the settings page widget.
  @override
  Widget build(BuildContext context) {
    String title = "Settings Page";
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Text(title),
          // const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              context.pushReplacement('/');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          )
        ])));
  }
}
