import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../messages_page.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.peerId});
  final String peerId;

  @override
  Widget build(BuildContext context) {
    /// Get peer user data
    Future<DocumentSnapshot<Map<String, dynamic>>> getPeerInfo() async {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('User').doc(peerId).get();
      return snapshot;
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getPeerInfo(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> peerInfo = snapshot.data!.data()!;
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MessagesPage(
                            peerId: peerId,
                            peerNickname: peerInfo['firstName'],
                          ))),
              child: Container(
                margin: const EdgeInsets.only(
                    top: 5.0, bottom: 5.0, right: 10.0, left: 10.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                decoration: const BoxDecoration(
                    color: Color(0xFFFFEFEE),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        peerInfo['photoIndex'] != ""
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    peerInfo['photoIndex'].toString()),
                              )
                            : const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey,
                              ),
                        const SizedBox(
                          height: 10.0,
                          width: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              peerInfo['firstName'],
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
