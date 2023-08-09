import 'package:carpool_app/main/widgets/host_history.dart';
import 'package:carpool_app/main/widgets/rider_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPage();
}

class _RideHistoryPage extends State<RideHistoryPage> {
  int option = 1;

  @override
  void initState() {
    super.initState();
    option = 1;
  }

  // This widget is the ride history page.
  @override
  Widget build(BuildContext context) {
    String title = "Ride History";
    final ButtonStyle style = ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            // Ride History Organization Buttons
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {
                      option = 1;
                    });
                  },
                  child: const Text(
                    'All Rides',
                    style: TextStyle(color: Colors.black),
                  )),
              ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {
                      option = 2;
                    });
                    ;
                  },
                  child: const Text('Hosted Rides',
                      style: TextStyle(color: Colors.black))),
              ElevatedButton(
                style: style,
                onPressed: () {
                  setState(() {
                    option = 3;
                  });
                },
                child: const Text('Passenger Rides',
                    style: TextStyle(color: Colors.black)),
              ),
            ]),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('ride-post')
                  .orderBy('destinationDateTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final documents = snapshot.data!.docs;
                  return Center(
                    child: Column(children: [
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            final documentData = documents[index].data();
                            final documentId = documents[index].id;
                            final riderId = documentData['hosterId'];
                            final now = DateTime.now();
                            // Check if past ride
                            if (now.isAfter(DateTime.fromMillisecondsSinceEpoch(
                                documentData['destinationDateTime']))) {
                              // Check if passenger
                              if (option == 1 || option == 3) {
                                for (int i = 0;
                                    i < documentData['riderIds'].length;
                                    i++) {
                                  if (documentData['riderIds'].containsKey(
                                      FirebaseAuth.instance.currentUser!.uid)) {
                                    return RiderHistoryCard(
                                      myRidesData: documentData,
                                      documentId: documentId,
                                    );
                                  }
                                }
                              }
                              //}

                              if (option == 1 || option == 2) {
                                // Check if host
                                if (riderId ==
                                    FirebaseAuth.instance.currentUser!.uid) {
                                  return HostHistoryCard(
                                      hostRideData: documentData,
                                      documentId: documentId);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }
                            }
                            return const SizedBox.shrink();
                          }),
                    ]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        )));
  }
}
