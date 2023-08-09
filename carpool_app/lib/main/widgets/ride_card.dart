import 'package:carpool_app/main/utils/chat_page_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../messages_page.dart';
import '../post_detail_page.dart';
import '../utils/rides_page_utils.dart';

class MyRidesRideCard extends StatelessWidget {
  const MyRidesRideCard(
      {super.key, required this.myRidesData, required this.documentId});
  final Map<String, dynamic> myRidesData;
  final String documentId;
  @override
  Widget build(BuildContext context) {
    /// Returns the width of the screen
    double width = MediaQuery.of(context).size.width;

    /// Returns document snapshot of the user who is a driver
    Future<DocumentSnapshot<Map<String, dynamic>>> getDocument() async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(myRidesData['hosterId'])
          .get();
      return snapshot;
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getDocument(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> driver = snapshot.data!.data()!;
            String formattedPickUpTime =
                getFormattedTime(myRidesData['pickUpDateTime']);
            String currentUserId = FirebaseAuth.instance.currentUser!.uid;
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostDetailPage(postId: documentId))),
              child: Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: driver['photoIndex'] != ""
                            ? CircleAvatar(
                                radius: width * .08,
                                backgroundImage: NetworkImage(
                                    driver['photoIndex'].toString()),
                              )
                            : CircleAvatar(
                                radius: width * .08,
                                backgroundColor: Colors.grey,
                              ),
                        title: Text(
                          "${driver['firstName']} ${driver['lastName']}",
                          style: const TextStyle(
                              color: Color.fromARGB(157, 0, 0, 0),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("$formattedPickUpTime\n"
                            "${myRidesData['pickUpAddr']}"),
                        trailing: myRidesData["riderIds"][currentUserId] ==
                                "accepted"
                            ? IconButton(
                                icon: Icon(Icons.message_rounded),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => MessagesPage(
                                                peerId: myRidesData['hosterId'],
                                                peerNickname:
                                                    driver['firstName'],
                                              )));
                                },
                              )
                            : const SizedBox.shrink(),
                        isThreeLine: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          myRidesData["riderIds"][currentUserId] == "pending"
                              ? const Text(
                                  "pending...",
                                  style: TextStyle(
                                      color: Color.fromARGB(115, 52, 150, 131),
                                      fontSize: 16),
                                )
                              : SizedBox.shrink(),
                          SizedBox(
                            width: 140,
                          ),
                          TextButton(
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(color: Colors.black45),
                            ),
                            onPressed: () {
                              // remove rider from riderIds field in host-post
                              deleteExistingRider(documentId,
                                  FirebaseAuth.instance.currentUser!.uid);
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
