import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../messages_page.dart';
import '../utils/chat_page_utils.dart';

class NotificationComponent extends StatefulWidget {
  const NotificationComponent(
      {super.key, required this.data, this.riderId, required this.documentId});
  final Map<String, dynamic> data;
  final String? riderId;
  final String documentId;

  @override
  State<NotificationComponent> createState() => _NotificationComponentState();
}

class _NotificationComponentState extends State<NotificationComponent> {
  bool _showWidget = true;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String formattedPickUpTime =
        getFormattedTime(widget.data['pickUpDateTime']);

    /// returns document snapshot of the information of the rider
    Future<DocumentSnapshot<Map<String, dynamic>>> getRiderInfo(
        String? riderId) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(riderId)
          .get();
      return snapshot;
    }

    /// returns document snapshot of the information of the driver
    Future<DocumentSnapshot<Map<String, dynamic>>> getDriverInfo() async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(widget.data['hosterId'])
          .get();
      return snapshot;
    }

    // if the current user is the hoster of the ride
    return currentUserId == widget.data['hosterId']
        ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getRiderInfo(widget.riderId!),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> rider = snapshot.data!.data()!;
                return Center(
                  child: Card(
                    child: Column(children: [
                      ListTile(
                        leading: rider['photoIndex'] != ""
                            ? CircleAvatar(
                                radius: width * .08,
                                backgroundImage: NetworkImage(
                                    rider['photoIndex'].toString()),
                              )
                            : CircleAvatar(
                                radius: width * .08,
                                backgroundColor: Colors.grey,
                              ),
                        title: Text(
                          "${rider['firstName']} ${rider['lastName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              const TextSpan(
                                  text: 'has requested to join your Carpool: '),
                              TextSpan(
                                  text: '\n$formattedPickUpTime',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            child: const Text(
                              'ACCEPT',
                              style: TextStyle(color: Colors.black45),
                            ),
                            onPressed: () {
                              updateRideStatus(widget.documentId,
                                  widget.riderId, "accepted");
                            },
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            child: const Text(
                              'DECLINE',
                              style: TextStyle(color: Colors.black45),
                            ),
                            onPressed: () {
                              updateRideStatus(widget.documentId,
                                  widget.riderId, "declined");
                            },
                          ),
                        ],
                      ),
                    ]),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )
        // if the current user is the rider of the ride
        : _showWidget == true
            ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getDriverInfo(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> driver = snapshot.data!.data()!;
                    return Center(
                      child: Card(
                        child: Column(children: [
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          'has ${widget.data['riderIds'][currentUserId]} your Carpool: '),
                                  TextSpan(
                                      text: '\n$formattedPickUpTime',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            isThreeLine: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              widget.data['riderIds'][currentUserId] ==
                                      "declined"
                                  ? const SizedBox.shrink()
                                  : TextButton(
                                      child: const Text(
                                        'GO TO CHAT',
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => MessagesPage(
                                                      peerId: widget
                                                          .data['hosterId'],
                                                      peerNickname:
                                                          driver['firstName'],
                                                    )));
                                      },
                                    ),
                              const SizedBox(width: 8),
                              TextButton(
                                child: const Text(
                                  'OK',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showWidget = false;
                                  });
                                },
                              ),
                            ],
                          )
                        ]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                })
            : const SizedBox.shrink();
  }
}
