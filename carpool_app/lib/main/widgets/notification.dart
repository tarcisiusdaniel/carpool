import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'notification_component.dart';

class NotificationDropDown extends StatelessWidget {
  const NotificationDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('ride-post').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final documents = snapshot.data!.docs;
            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
            return Center(
              child: ExpansionTile(
                textColor: Colors.red,
                title: const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index].data();
                      final documentId = documents[index].id;
                      // when currentUser is a rider
                      Map<String, String> riderIds =
                          Map.from(document['riderIds']);
                      if (riderIds.containsKey(currentUserId) &&
                          riderIds[currentUserId] != "pending") {
                        return NotificationComponent(
                            data: document, documentId: documentId);
                      }
                      // when currentUser is a driver and recieve pending request
                      else if (document['hosterId'] == currentUserId) {
                        Iterable<MapEntry<String, String>> entries =
                            riderIds.entries;
                        for (MapEntry<String, String> entry in entries) {
                          if (entry.value == "pending") {
                            return NotificationComponent(
                              data: document,
                              riderId: entry.key,
                              documentId: documentId,
                            );
                          }
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
