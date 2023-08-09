import 'package:carpool_app/main/messages_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_listtile.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        textColor: Colors.red,
        title: const Text(
          "Recent Chats",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        children: [
          Container(
              height: 300.0,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0))),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                child: StreamBuilder<dynamic>(
                    stream: FirebaseFirestore.instance
                        .collection('ride-post')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final documents = snapshot.data!.docs;
                        return ListView.builder(
                            itemCount: documents!.length,
                            itemBuilder: (BuildContext context, index) {
                              final currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final post = documents[index].data()
                                  as Map<String, dynamic>;
                              final driverId = post['hosterId'];
                              Map<String, String> riderIds =
                                  Map.from(post['riderIds']);
                              Iterable<MapEntry<String, String>> entries =
                                  riderIds.entries;
                              // if current user is the driver, he/she is allowed to chat with user who is accepted in the ride.
                              if (driverId == currentUserId) {
                                for (MapEntry<String, String> entry
                                    in entries) {
                                  if (entry.value == "accepted") {
                                    return ChatTile(
                                      peerId: entry.key,
                                    );
                                  }
                                }
                              }
                              // if current user is not the driver, he can chat with the driver who accepted the request.
                              else if (riderIds.containsKey(currentUserId) &&
                                  riderIds[currentUserId] == "accepted") {
                                return ChatTile(peerId: driverId);
                              }
                              return const SizedBox.shrink();
                            });
                      }
                      return const Text('no user data');
                    }),
              )),
        ]);
  }
}
