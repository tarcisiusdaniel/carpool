import 'package:carpool_app/main/chat_page.dart';
import 'package:carpool_app/main/host_page.dart';
import 'package:carpool_app/main/landing_page.dart';
import 'package:carpool_app/main/rides_page.dart';
import 'package:carpool_app/main/settings_page.dart';
import 'package:carpool_app/main/post_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List pages = [
    LandingPage(),
    HostPage(),
    RidesPage(),
    ChatPage(),
    SettingsPage(),
  ];

  int currentIndex = 0;

  /// Switch the index between pages
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(label: "Landing", icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: "Host", icon: Icon(Icons.directions_car)),
          BottomNavigationBarItem(label: "Rides", icon: Icon(Icons.group)),
          BottomNavigationBarItem(label: "Chat", icon: Icon(Icons.chat_bubble)),
          BottomNavigationBarItem(
              label: "Settings", icon: Icon(Icons.settings)),
        ],
      ),
    );
  }
}
