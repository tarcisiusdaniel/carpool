import 'package:carpool_app/main/utils/chat_page_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../post_detail_page.dart';

class RiderHistoryCard extends StatelessWidget {
  const RiderHistoryCard(
      {super.key, required this.myRidesData, required this.documentId});
  final Map<String, dynamic> myRidesData;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Future<DocumentSnapshot<Map<String, dynamic>>> getDriverDocument() async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(myRidesData['hosterId'])
          .get();
      return snapshot;
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getDriverDocument(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> driver = snapshot.data!.data()!;
            String formattedPickUpTime =
                getFormattedTimeWithYear(myRidesData['pickUpDateTime']);
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
                          "Driver: ${driver['firstName']} ${driver['lastName']}",
                          style: const TextStyle(
                              color: Color.fromARGB(157, 0, 0, 0),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("$formattedPickUpTime\n"
                            "To: ${myRidesData['pickUpAddr']}"),
                        isThreeLine: true,
                      ),
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
