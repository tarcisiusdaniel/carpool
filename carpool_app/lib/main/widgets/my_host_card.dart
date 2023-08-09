import 'package:carpool_app/main/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../messages_page.dart';
import '../post_detail_page.dart';
import '../utils/chat_page_utils.dart';
import '../utils/rides_page_utils.dart';

class RidesMyHostCard extends StatelessWidget {
  const RidesMyHostCard(
      {super.key, required this.hostRideData, required this.documentId});
  final Map<String, dynamic> hostRideData;
  final String documentId;

  /// Returns document snapshot of the user
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot;
  }

  /// Returns list of document snapshots of the riders
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      getRiderDocuments() async {
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
      future: getUserDocument(),
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
                    ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      leading: userInfo['photoIndex'] != ""
                          ? CircleAvatar(
                              radius: width * .08,
                              backgroundImage: NetworkImage(
                                  userInfo['photoIndex'].toString()),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey,
                            ),
                      title: Text(
                        getFormattedTime(hostRideData['pickUpDateTime']),
                        // DateFormat('EEEE, ha, MMM d')
                        //     .format(hostRideData['pickUpDateTime'].toDate()),
                        style: const TextStyle(
                            color: Color.fromARGB(157, 0, 0, 0),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("From: ${hostRideData['pickUpAddr']}"
                          "\nTO: ${hostRideData['destinationAddr']}"),
                      isThreeLine: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: 80,
                          child: FutureBuilder(
                              future: getRiderDocuments(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          List<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        'Error fetching snapshot: ${snapshot.error}');
                                  } else {
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
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              const ChatPage()));
                                                },
                                                child: (rider['photoIndex'] !=
                                                            "" &&
                                                        rider['photoIndex'] !=
                                                            null)
                                                    ? CircleAvatar(
                                                        radius: width * .08,
                                                        backgroundImage:
                                                            NetworkImage(rider[
                                                                'photoIndex']),
                                                      )
                                                    : CircleAvatar(
                                                        radius: width * .08,
                                                        backgroundColor:
                                                            Colors.grey,
                                                      ),
                                              ));
                                        });
                                  }
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.black45),
                          ),
                          onPressed: () {
                            deleteExistingRide(documentId);
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
      },
    );
  }
}
