import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../post_detail_page.dart';
import '../utils/chat_page_utils.dart';

class HostHistoryCard extends StatelessWidget {
  const HostHistoryCard(
      {super.key, required this.hostRideData, required this.documentId});
  final Map<String, dynamic> hostRideData;
  final String documentId;

  Future<DocumentSnapshot<Map<String, dynamic>>> getHostDocument() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      getRidersDocuments() async {
    List<String> keys = hostRideData["riderIds"].keys.toList();
    List<DocumentSnapshot<Map<String, dynamic>>> riderDocs = [];
    for (int i = 0; i < keys.length; i++) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(keys[i])
          .get();
      riderDocs.add(snapshot);
    }
    return riderDocs;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: getHostDocument(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> userInfo = snapshot.data!.data()!;
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
                    // Host
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      leading: userInfo['photoIndex'] != ""
                          ? CircleAvatar(
                              radius: width * .08,
                              backgroundImage: NetworkImage(
                                  userInfo['photoIndex'].toString()),
                            )
                          : CircleAvatar(
                              radius: width * .08,
                              backgroundColor: Colors.grey,
                            ),
                      title: Text(
                        getFormattedTimeWithYear(
                            hostRideData['pickUpDateTime']),
                        style: const TextStyle(
                            color: Color.fromARGB(157, 0, 0, 0),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("From: ${hostRideData['pickUpAddr']}"
                          "\nTo: ${hostRideData['destinationAddr']}"),
                    ),

                    // Riders
                    ListTile(
                      contentPadding: EdgeInsets.only(left: width * .2),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 80,
                            child: FutureBuilder(
                                future: getRidersDocuments(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            List<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount:
                                            hostRideData["riderIds"].length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          Map<String, dynamic> rider =
                                              snapshot.data![index].data()!;
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: (rider['photoIndex'] != "" &&
                                                    rider['photoIndex'] != null)
                                                ? CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            rider['photoIndex']
                                                                .toString()),
                                                  )
                                                : const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.grey,
                                                  ),
                                          );
                                        });
                                  }
                                  return const SizedBox.shrink();
                                }),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
