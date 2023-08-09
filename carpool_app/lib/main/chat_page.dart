import 'package:carpool_app/main/widgets/notification.dart';
import 'package:carpool_app/main/widgets/recent_chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carpool_app/main/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'auth_pages/login_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String title = "Chat";
  User? currentUser;

  @override
  void initState() {
    super.initState();
    // _signIn(EMAIL, PASSWORD);
    // getData();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Chats";
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
          actions: <Widget>[
            IconButton(
                key: const Key('profile-button'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()));
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                ))
          ],
        ),
        body: Consumer<ApplicationState>(
            builder: (context, appState, _) => appState.loggedIn &&
                    appState.userPopulated
                ? SingleChildScrollView(
                    child: Column(
                      children: const [NotificationDropDown(), RecentChats()],
                    ),
                  )
                : LoginPage()));
  }
}

Stream<QuerySnapshot> getFirestoreData(
    String collectionPath, int limit, String? textSearch) {
  if (textSearch?.isNotEmpty == true) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .limit(limit)
        .where("displayName", isEqualTo: textSearch)
        .snapshots();
  } else {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .limit(limit)
        .snapshots();
  }
}
